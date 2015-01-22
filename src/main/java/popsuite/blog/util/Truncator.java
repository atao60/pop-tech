package popsuite.blog.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.AutoDetectParser;
import org.apache.tika.parser.ParseContext;
import org.apache.tika.parser.Parser;
import org.xml.sax.ContentHandler;

import popsuite.blog.util.TruncateContentHandler.Unit;

/**
 * Wrap Tika HTML parser (based on Tagsoup) with TruncateContentHandler and ToXmlContentHandler
 * to create an excerpt of an HTML fragment. This excerpt is ready to be inserted as valid HTML
 * in a final document.
 */
public class Truncator {
    
    private enum TruncationStatus { 
        unknow, truncated, unchanged
    }

    private static final String  HTML_CONTENT_TYPE  = "text/html";
    private static final int     NO_LIMIT           = TruncateContentHandler.NO_LIMIT;
    private static final String  ELLIPSIS_TAG = "@@@ellipsis***tag@@@";
    private static final int     DEFAULT_LIMIT      = 60;
    private static final Charset DEFAULT_CHARSET    = StandardCharsets.UTF_8;
    private static final Unit    DEFAULT_UNIT       = Unit.word;
    private static final boolean DEFAULT_COUNTING_WITH_SPACES = false;
    private static final boolean DEFAULT_SMART_TRUNCATION     = true;
    private static final String  DEFAULT_ELLIPSIS             = "...";
    private static final TruncationStatus  DEFAULT_TRUNCATION_STATUS    = TruncationStatus.unknow;
    
    private final Unit unit;
    private final int limit;
    private final Charset charset;
    
    private String  source;
    private boolean countingWithSpaces = DEFAULT_COUNTING_WITH_SPACES;
    private boolean smartTruncation = DEFAULT_SMART_TRUNCATION;
    private String  ellipsis = DEFAULT_ELLIPSIS;
    private TruncationStatus    truncationStatus    = DEFAULT_TRUNCATION_STATUS;
    
    public Truncator()  {
        this(DEFAULT_UNIT, DEFAULT_LIMIT, DEFAULT_CHARSET);
    }

    public Truncator(final int limit)  {
        this(DEFAULT_UNIT, limit, DEFAULT_CHARSET);
    }

    public Truncator(final Unit unit, final int limit, final Charset charset)  {
        if (limit < NO_LIMIT)
            throw new IllegalArgumentException("Either no limit (-1), zero or positive number as limit.");
        if (unit == null)
            throw new IllegalArgumentException("The count type (word, character or code point) must be defined.");
        if (charset == null)
            throw new IllegalArgumentException("Charset can't be null.");

        this.unit = unit;
        this.limit = limit;
        this.charset = charset;
    }
    
    public Truncator source(final String source) {
        if (source == null) 
            throw new IllegalArgumentException("The source can't be null.");
        
        this.source = source;
        truncationStatus = TruncationStatus.unknow;
        return this;
    }
    
    public Truncator countingWithSpaces(final boolean countingWithSpaces) {
        this.countingWithSpaces = countingWithSpaces;
        truncationStatus = TruncationStatus.unknow;
        return this;
    }
    
    public Truncator smartTruncation(final boolean smartTruncation) {
        this.smartTruncation = smartTruncation;
        truncationStatus = TruncationStatus.unknow;
        return this;
    }
    
    public Truncator ellipsis(final String ellipsis) {
        if (ellipsis == null) 
            throw new IllegalArgumentException("The ellipsis can't be null.");
        
        this.ellipsis = ellipsis;
        return this;
    }
    
    public boolean isTroncated() {
        if (truncationStatus == TruncationStatus.unknow)
            throw new IllegalStateException("Run the truncator before asking.");
        return truncationStatus == TruncationStatus.truncated;
    }
    
    public String run() throws Exception {
        if (source == null) 
            throw new IllegalStateException("Not ready: a source is required.");

        byte[] buffer = null;

        // generate a complete and valid xml document from the fragment 
        // then truncate it

        try (InputStream is = new ByteArrayInputStream(source.getBytes(charset));
                        ByteArrayOutputStream os = new ByteArrayOutputStream()) {

            ContentHandler textHandler = new ToXmlContentHandler(os, charset);

            // ignore the spaces
            TruncateContentHandler writerhandler = new TruncateContentHandler(textHandler, limit);
            writerhandler.setCountingWithSpaces(countingWithSpaces);
            writerhandler.setWithSmartTruncation(smartTruncation);
            writerhandler.setUnit(unit);

            Parser parser = new AutoDetectParser();
            Metadata metadata = new Metadata();
            metadata.add(Metadata.CONTENT_TYPE, HTML_CONTENT_TYPE);
            truncationStatus = TruncationStatus.unchanged;
            try {
                parser.parse(is, writerhandler, metadata, new ParseContext());
            } catch (Exception e) {
                if (!writerhandler.isWriteLimitReached(e))
                    throw e;
                
                writerhandler.endDocument();
                os.write(ELLIPSIS_TAG.getBytes(charset));
                truncationStatus = TruncationStatus.truncated;
            }
            buffer = os.toByteArray();
        }

        // close all the tags left open after the truncature to get a complete
        // and valid xml document

        try (InputStream is = new ByteArrayInputStream(buffer); 
                        ByteArrayOutputStream os = new ByteArrayOutputStream()) {
            
            ContentHandler textHandler = new ToXmlContentHandler(os, charset);

            Parser parser = new AutoDetectParser();
            Metadata metadata = new Metadata();
            metadata.add(Metadata.CONTENT_TYPE, HTML_CONTENT_TYPE);
            parser.parse(is, textHandler, metadata, new ParseContext());
            buffer = os.toByteArray();
        }

        // keep only the truncated fragment, i.e. the content of the "body"
        // element
        // a regex can be used here as there is only one body element and it's a valid
        // html document (thanks to tagsoup).

        String result = new String(buffer).replaceAll("(?s)^.*<body>(.*)</body></html>$", "$1");
        if (isTroncated()) {
            result = result.replace(ELLIPSIS_TAG, ellipsis);
        }
        return result;
    }

}
