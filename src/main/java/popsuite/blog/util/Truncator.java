package popsuite.blog.util;

import static popsuite.blog.util.TruncateContentHandler.SPACE_PATTERN_BASE;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
    private static final String  READ_MORE_TAG      = "@@@readmore***tag@@@";
    private static final int     DEFAULT_LIMIT      = 60;
    private static final Charset DEFAULT_CHARSET    = StandardCharsets.UTF_8;
    private static final Unit    DEFAULT_UNIT       = Unit.word;
    private static final boolean DEFAULT_COUNTING_WITH_SPACES = false;
    private static final boolean DEFAULT_SMART_TRUNCATION     = true;
    private static final String  DEFAULT_ELLIPSIS             = "...";
    private static final String  DEFAULT_READ_MORE            = "";
    private static final TruncationStatus  DEFAULT_TRUNCATION_STATUS    = TruncationStatus.unknow;
    
    private final Unit unit;
    private final int limit;
    private final Charset charset;
    
    private String  source;
    private boolean countingWithSpaces = DEFAULT_COUNTING_WITH_SPACES;
    private boolean smartTruncation = DEFAULT_SMART_TRUNCATION;
    private String  ellipsis = DEFAULT_ELLIPSIS;
    private String  readmore = DEFAULT_READ_MORE;
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
    
    public Truncator readmore(final String readmore) {
        if (readmore == null) 
            throw new IllegalArgumentException("The 'Read More' message can't be null.");
        
        this.readmore = readmore;
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
        String currentElementName = "";

        // generate a complete and valid xml document from the fragment 
        // then truncate it

        try (InputStream is = new ByteArrayInputStream(source.getBytes(charset));
                        ByteArrayOutputStream os = new ByteArrayOutputStream()) {

            ToXmlContentHandler textHandler = new ToXmlContentHandler(os, charset);

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
                truncationStatus = TruncationStatus.truncated;
                if(textHandler.getCurrentElementName().matches("^(?:[^:]+:)?a$")) {
                    currentElementName =  textHandler.getCurrentElementName();
                }
                
            }
            buffer = os.toByteArray();
        }
        
        /*
           Tagsoup doesn't like link with attributes inside the "read more": it removes the attributes! So we need here
           a late substitution. Then you are solely responsible for the readmore content.
         */
        if (isTroncated()) {
            String truncated = new String(buffer, charset.name());
            if(currentElementName.isEmpty()) {
                truncated += ellipsis;
                truncated += READ_MORE_TAG;
            } else {
                String unclosedPattern = "(?s)"  + SPACE_PATTERN_BASE + "*<%s\\s.*>" + SPACE_PATTERN_BASE + "*$";
                Pattern pattern = Pattern.compile(unclosedPattern);
                Matcher matcher = pattern.matcher(truncated);
                if (matcher.find()) {
                    StringBuffer sb = new StringBuffer();
                    matcher.appendReplacement(sb, "");
                    truncated = sb.toString();
                    truncated += ellipsis;
                    truncated += READ_MORE_TAG;                    
                } else {
                    truncated += ellipsis;
                    truncated += "</" + currentElementName + ">";
                    truncated += READ_MORE_TAG;
                }
            }
            buffer = truncated.getBytes(charset);
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

        /* keep only the truncated fragment, i.e. the content of the "body" element
           a regex can be used here as there is only one body element and it's a valid
           html document (thanks to tagsoup).
           */
        String result = new String(buffer);
        result = result.replaceFirst("(?s)^.*<body>(.*)</body></html>$", "$1");
        
        if (isTroncated()) {
            result = result.replace(READ_MORE_TAG, readmore);
        }
        return result;
    }
}
