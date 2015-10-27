package popsuite.blog.util

import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.UnsupportedEncodingException
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.util.regex.Pattern
import org.apache.tika.exception.TikaException
import org.apache.tika.metadata.Metadata
import org.apache.tika.parser.AutoDetectParser
import org.apache.tika.parser.ParseContext
import org.xml.sax.SAXException
import popsuite.blog.util.TruncateContentHandler.Unit

import static java.lang.String.format
import static popsuite.blog.util.TruncateContentHandler.SPACE_PATTERN
import static popsuite.blog.util.TruncateContentHandler.SPACE_PATTERN_BASE

/**
 * Wrap Tika HTML parser (based on Tagsoup) with TruncateContentHandler and
 * ToXmlContentHandler to create an excerpt of an HTML fragment. This excerpt is
 * ready to be inserted as valid HTML in a final document.
 */
class Truncator {

    private enum TruncationStatus {
        unknown, truncated, unchanged
    }

    val static            HTML_CONTENT_TYPE                          = "text/html"
    val static            NO_LIMIT                                   = TruncateContentHandler.NO_LIMIT
    val static            READ_MORE_TAG                              = "@@@readmore***tag@@@";
    val static            DEFAULT_LIMIT                              = 60
    val static            DEFAULT_CHARSET                            = StandardCharsets.UTF_8
    val static            DEFAULT_UNIT                               = Unit.word
    val static            DEFAULT_COUNTING_WITH_SPACES               = false
    val static            DEFAULT_SMART_TRUNCATION                   = true
    val static            DEFAULT_ELLIPSIS                           = "..."
    val static            DEFAULT_READ_MORE                          = ""
    val static            DEFAULT_TRUNCATION_STATUS                  = TruncationStatus.unknown
    val static            EMPTY_STRING                               = ""
    val static            HTML_TAG_NAME_WITH_PREFIX                  = "^(?:[^:]+:)?a$"
    val static            HTML_BODY_TAG_CONTENT                      = "(?s)^.*<body>(.*)</body>\\s*</html>\\s*$"
    val static            KEEP_ONLY_THE_SELECTION                    = "$1"
    val static            CLOSING_HTML_TAG                           = "</%s>"
    val static            UNCLOSED_HTML_TAG_WITH_BLANK_HEAD_AND_TAIL = "(?s)"
                    + SPACE_PATTERN
                    + "*<%s(?:>|\\s[^>]*[^/]>)"
                    + SPACE_PATTERN
                    + "*$"
    public val static     ELISIONABLED                               ="[j|t|d|l|qu|s|m|n]"
    public val static     FRENCH_ELISION                             ="['|\\u2019|\\u02bc]"

    val Unit                    unit
    val int                     limit
    val Charset                 charset

    var String                  source
    var                         countingWithSpaces                         = DEFAULT_COUNTING_WITH_SPACES
    var                         smartTruncation                            = DEFAULT_SMART_TRUNCATION
    var                         ellipsis                                   = DEFAULT_ELLIPSIS
    var                         readmore                                   = DEFAULT_READ_MORE
    var                         truncationStatus                           = DEFAULT_TRUNCATION_STATUS

    new() {
        this(DEFAULT_UNIT, DEFAULT_LIMIT, DEFAULT_CHARSET)
    }

    new(int limit) {
        this(DEFAULT_UNIT, limit, DEFAULT_CHARSET)
    }

    public new(Unit unit, int limit, Charset charset) {
        if (limit < NO_LIMIT)
            throw new IllegalArgumentException("Either no limit (-1), zero or positive number as limit.")
        if (unit === null)
            throw new IllegalArgumentException("The count type (word, character or code point) must be defined.")
        if (charset === null)
            throw new IllegalArgumentException("Charset can't be null.")

        this.unit = unit
        this.limit = limit
        this.charset = charset
    }

    def source(String source) {
        if (source === null)
            throw new IllegalArgumentException("The source can't be null.")

        this.source = source
        truncationStatus = TruncationStatus.unknown
        this
    }

    def countingWithSpaces(boolean countingWithSpaces) {
        this.countingWithSpaces = countingWithSpaces
        truncationStatus = TruncationStatus.unknown
        this
    }

    def smartTruncation(boolean smartTruncation) {
        this.smartTruncation = smartTruncation
        truncationStatus = TruncationStatus.unknown
        this
    }

    def ellipsis(String ellipsis) {
        if (ellipsis === null)
            throw new IllegalArgumentException("The ellipsis can't be null.")

        this.ellipsis = ellipsis
        this
    }

    def readmore(String readmore) {
        if (readmore === null)
            throw new IllegalArgumentException("The 'Read More' message can't be null.")

        this.readmore = readmore
        this
    }

    def isTroncated() {
        if (truncationStatus === TruncationStatus.unknown)
            throw new IllegalStateException("Run the truncator before asking.")
        truncationStatus == TruncationStatus.truncated
    }

    def run() throws Exception {
        if (source === null)
            throw new IllegalStateException("Not ready: a source is required.")

        val doc = createFullValidXmlDocFromFragment

        var buffer = removeOpenLink(doc.buffer, doc.currentElementName)
        
        buffer = closeAllTagsLeftOpenAfterTruncature(buffer)

        keepOnlyBodyContent(buffer)
    }

    private static class TruncatedDoc {
        val String currentElementName
        val byte[] buffer

        new(byte[] buffer, String currentElementName) {
            super()
            this.currentElementName = currentElementName
            this.buffer = buffer
        }

        def String getCurrentElementName() {
            currentElementName
        }

        def byte[] getBuffer() {
            buffer
        }
    }

    /*
     * Generate a complete and valid xml document from the fragment then
     * truncate it
     */
    private def createFullValidXmlDocFromFragment() 
    throws Exception {
            val is = new ByteArrayInputStream(source.getBytes(charset))
            val os = new ByteArrayOutputStream

            var elementName = EMPTY_STRING
            val textHandler = new ToXmlContentHandler(os, charset)

            // ignore the spaces
            val writerhandler = new TruncateContentHandler(textHandler, limit)
            writerhandler.countingWithSpaces = countingWithSpaces
            writerhandler.withSmartTruncation = smartTruncation
            writerhandler.unit = unit

            val parser = new AutoDetectParser
            val metadata = new Metadata
            metadata.add(Metadata.CONTENT_TYPE, HTML_CONTENT_TYPE)
            truncationStatus = TruncationStatus.unchanged
            try {
                parser.parse(is, writerhandler, metadata, new ParseContext)
            } catch (Exception e) {
                if (! writerhandler.isWriteLimitReached(e))
                    throw e

                writerhandler.endDocument
                truncationStatus = TruncationStatus.truncated
                if (textHandler.currentElementName.matches(HTML_TAG_NAME_WITH_PREFIX)) {
                    elementName = textHandler.currentElementName
                }

            }
            
            val result = os.toByteArray

            new TruncatedDoc(result, elementName)
        
    }

    /*
     * Keep only the truncated fragment, i.e. the content of the "body" element
     * a regex can be used here as there is only one body element and it's a
     * valid html document (thanks to tagsoup).
     */
    private def keepOnlyBodyContent(byte[] buffer) {
        var result = new String(buffer)
        result = result.replaceFirst(HTML_BODY_TAG_CONTENT, KEEP_ONLY_THE_SELECTION)

        if (! isTroncated) return result

        result.replace(READ_MORE_TAG, readmore)

    }

    /*
     * Close all the tags left open after the truncature to get a complete and
     * valid xml document
     */
    private def closeAllTagsLeftOpenAfterTruncature(byte[] buffer) 
    throws IOException, SAXException,
                    TikaException {
        if (! isTroncated) return buffer

            val is = new ByteArrayInputStream(buffer)
            val os = new ByteArrayOutputStream

            val textHandler = new ToXmlContentHandler(os, charset)

            val parser = new AutoDetectParser
            val metadata = new Metadata
            metadata.add(Metadata.CONTENT_TYPE, HTML_CONTENT_TYPE)
            parser.parse(is, textHandler, metadata, new ParseContext)
            os.toByteArray
        
    }

    /*
     * Tagsoup doesn't like link with attributes inside the "read more": it
     * removes the attributes! So we need here a late substitution. Then you are
     * solely responsible for the readmore content.
     */
    private def removeOpenLink(byte[] buffer, String currentElementName)
    throws UnsupportedEncodingException {
        if (! isTroncated) return buffer

        var truncated = new String(buffer, charset.name)

        if (currentElementName.isEmpty) {
            truncated = truncated.addEllipsis
            truncated = truncated.addReadMore
        } else {
            val unclosedEmptyPattern = format(UNCLOSED_HTML_TAG_WITH_BLANK_HEAD_AND_TAIL, currentElementName)
            val pattern = Pattern.compile(format(unclosedEmptyPattern, currentElementName))
            val matcher = pattern.matcher(truncated)
            if (matcher.find) {
                val sb = new StringBuffer
                matcher.appendReplacement(sb, EMPTY_STRING)
                truncated = sb.toString
                truncated = truncated.addEllipsis
                truncated = truncated.addReadMore
            } else {
                truncated = truncated.addEllipsis
                truncated += format(CLOSING_HTML_TAG, currentElementName)
                truncated = truncated.addReadMore
            }
        }
        truncated.getBytes(charset)

    }

    private def addReadMore(String text) {
        text + READ_MORE_TAG
    }
    
    private def addEllipsis(String text) {
        applySpecialFinalRules(text) + ellipsis
    }
    
    /*
     * ATM only some french rules
     */
    private def applySpecialFinalRules(String text) {

        val psb = new StringBuilder("(?s)" + SPACE_PATTERN + "(?:")
        psb.append("(?:\\u00ab" + SPACE_PATTERN + "?)")  //opening french quotation mark
        psb.append("|")
        psb.append("(?:" + ELISIONABLED + FRENCH_ELISION + ")")  //french elision apostrophe     
        psb.append("|")
        psb.append("(?:[^\\p{C}" + SPACE_PATTERN_BASE + "&&[^ày\\&]])")  //an orphan character but "à", "y" and "&"    
        psb.append(")$")
        
        val pattern = Pattern.compile(psb.toString)
        val matcher = pattern.matcher(text)
        if (matcher.find) {
            val sb = new StringBuffer
            matcher.appendReplacement(sb, EMPTY_STRING)
            sb.toString
        } else {
            text
        }
    }
}
