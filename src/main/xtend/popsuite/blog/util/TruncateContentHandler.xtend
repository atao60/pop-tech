package popsuite.blog.util

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.Serializable
import java.io.StringWriter
import java.io.Writer
import java.nio.charset.Charset
import java.util.Arrays
import java.util.UUID
import org.apache.tika.sax.ContentHandlerDecorator
import org.apache.tika.sax.ToTextContentHandler
//import org.apache.tika.sax.ToXMLContentHandler
//import org.apache.tika.sax.WriteOutContentHandler
import org.xml.sax.ContentHandler
import org.xml.sax.SAXException

/**
 * SAX event handler that writes content up to an optional limit to a character stream or other decorated handler.
 * This classe is based on {@link org.apache.tika.sax.WriteOutContentHandler} with some improvements.
 * The counter is now accessible by any derived classe. It's also possible to chose:
 * <li>the type of item to count: characters, Unicode code points or words</li>
 * <li>when counting characters or code points, if spaces has to be counted or not</li>
 * <li>when counting characters or code points, if the last word can be splitted or not</li>
 * 
 * Required {@link popsuite.blog.util.ToXmlContentHandler}: it doesn't work with the original {@link  org.apache.tika.sax.ToXMLContentHandler}. 
 */
class TruncateContentHandler extends ContentHandlerDecorator {

    public enum Unit {
        word, codePoint, character
    }
    
    public val static NO_LIMIT            = -1
    val static        DEFAULT_LIMIT       = 100 * 1000
    val static        DEFAULT_UNIT        = Unit.character

    val static        EMPTY_STRING        = ""
    /* SPACE_PATTERN_BASE must be defined in accordance with the method {@link #isSpace} for Unicode Cope Point */
    public val static SPACE_PATTERN_BASE  = "\\p{javaWhitespace}\\p{Z}"
    public val static SPACE_PATTERN       = "[" + SPACE_PATTERN_BASE + "]"
    val static        SPACES_PATTERN      = SPACE_PATTERN + "+"
    val static        NO_SPACE_PATTERN    = "[^" + SPACE_PATTERN_BASE + "]"
    val static        TRUNCATED_LAST_WORD = "(?s)" + SPACES_PATTERN + NO_SPACE_PATTERN + "*$"
    val static        WITH_DELIMITER_SPLITTER_PATTERN = "(?=(?!^)%1$s)(?<!%1$s)|(?!%1$s)(?<=%1$s)"
    val static        SPACES_TAIL         = "(?s)" + SPACES_PATTERN + "$"

    var              withSpaces          = true
    /* even with LF, FF, ... */
    var              withAllSpaces       = false
    var              withSmartTruncation = true
    var              unit                = DEFAULT_UNIT

    /**
     * The unique tag associated with exceptions from stream.
     */
    val              tag                 = UUID.randomUUID

    /**
     * The maximum number of characters to write to the character stream. Set to
     * -1 for no limit.
     */
    val int           writeLimit

    /**
     * Number of characters written so far.
     */
    var               writeCount          = 0

    /**
     * Creates a content handler that writes content up to the given write limit
     * to the given content handler.
     *
     * @param handler
     *            content handler to be decorated
     * @param writeLimit
     *            write limit
     */
    new(ContentHandler handler, int writeLimit) {
        super(handler)
        if (writeLimit < NO_LIMIT)
            throw new IllegalArgumentException("Either no limit (-1), zero or positive number as limit.")
        this.writeLimit = writeLimit
    }

    /**
     * Creates a content handler that writes content up to the given write limit
     * to the given character stream.
     *
     * @param writer
     *            character stream
     * @param writeLimit
     *            write limit
     */
    new(Writer writer, int writeLimit) {
        this(new ToTextContentHandler(writer), writeLimit)
    }

    /**
     * Creates a content handler that writes character events to the given
     * writer.
     *
     * @param writer
     *            writer
     */
    new(Writer writer) {
        this(writer, NO_LIMIT)
    }

    /**
     * Creates a content handler that writes character events to the given
     * output stream using the default encoding.
     *
     * @param stream
     *            output stream
     */
    new(OutputStream stream) {
        this(new OutputStreamWriter(stream, Charset.defaultCharset()))
    }

    /**
     * Creates a content handler that writes character events to an internal
     * string buffer. Use the {@link #toString()} method to access the collected
     * character content.
     * <p>
     * The internal string buffer is bounded at the given number of characters.
     * If this write limit is reached, then a {@link SAXException} is thrown.
     * The {@link #isWriteLimitReached(Throwable)} method can be used to detect
     * this case.
     *
     * @param writeLimit
     *            maximum number of characters to include in the string, or -1
     *            to disable the write limit
     */
    new(int writeLimit) {
        this(new StringWriter(), writeLimit)
    }

    /**
     * Creates a content handler that writes character events to an internal
     * string buffer. Use the {@link #toString()} method to access the collected
     * character content.
     * <p>
     * The internal string buffer is bounded at 100k characters. If this write
     * limit is reached, then a {@link SAXException} is thrown. The
     * {@link #isWriteLimitReached(Throwable)} method can be used to detect this
     * case.
     */
    new() {
        this(DEFAULT_LIMIT)
    }

    protected def getWriteLimit() {
        writeLimit
    }

    protected def isWriteLimitReached() {
        writeLimit != NO_LIMIT && writeLimit < writeCount
    }

    def isCountingWithSpaces() {
        withSpaces
    }

    def setCountingWithSpaces(boolean withSpaces) {
        this.withSpaces = withSpaces
    }

    def isCountingWithAllSpaces() {
        withAllSpaces
    }

    def setCountingWithAllSpaces(boolean withSpaces) {
        this.withAllSpaces = withSpaces
    }

    def isWithSmartTruncation() {
        withSmartTruncation
    }

    def setWithSmartTruncation(boolean smart) {
        this.withSmartTruncation = smart
    }

    def getUnit() {
        unit
    }

    def setUnit(Unit unit) {
        this.unit = unit
    }

    /**
     * Writes the given characters to the given character stream.
     */
    override void characters(char[] ch, int start, int length) 
    throws SAXException {
        if (unit == Unit.character) {
            countingByCharacter(ch, start, length)
        } else if (unit == Unit.codePoint) {
            countingByCodePoint(ch, start, length)
        } else {
            countingByWord(ch, start, length)
        }
    }

    private def void countingByCharacter(char[] ch, int start, int length) 
    throws SAXException {
        if (writeLimit == NO_LIMIT) {
            super.characters(ch, start, length)
            val origine = new String(Arrays.copyOfRange(ch, start, start + length))
            val stripped = if(isCountingWithSpaces) origine else origine.replaceAll(SPACES_PATTERN, EMPTY_STRING)
            writeCount += stripped.length
            return
        }

        var reached = false
        var next = start
        for (var i = start; !reached && i < start + length; i++) {
            next = i + 1
            if (isCountingWithSpaces || ! isSpace(ch.get(i))) {
                writeCount++
                if (writeCount >= writeLimit) reached = true
            }
        }
        val reachedBeforeEnd = reached && (next < start + length)
        if (reachedBeforeEnd && isWithSmartTruncation
                        && ((!isSpace(ch.get(next - 1)) && !isSpace(ch.get(next))) || isSpace(ch.get(next - 1)))) {
            val smartLentgh = new String(Arrays.copyOfRange(ch, start, next)).replaceFirst(TRUNCATED_LAST_WORD,
                            EMPTY_STRING).length
            next = start + smartLentgh
        }
        super.characters(ch, start, next - start)
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " Unicode unit points (characters), and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag)

    }

    private def void countingByCodePoint(char[] ch, int start, int length) throws SAXException {
        val origine = new String(Arrays.copyOfRange(ch, start, start + length))
        if (writeLimit == NO_LIMIT || length == 0) {
            super.characters(ch, start, length)
            val stripped = if(isCountingWithSpaces) origine else origine.replaceAll(SPACES_PATTERN, EMPTY_STRING)
            writeCount += stripped.codePointCount(0, stripped.length)
            return
        }

        var reached = false
        var next = 0
        var current = 0
        for (var i = 0; ! reached && i < origine.codePointCount(0, origine.length); i++) {
            current = origine.offsetByCodePoints(0, i)
            val currentCodePoint = origine.codePointAt(current)
            next = current + Character.charCount(currentCodePoint)
            if (isCountingWithSpaces || ! isSpace(currentCodePoint)) {
                writeCount++
                if (writeCount >= writeLimit) reached = true
            }
        }
        val reachedBeforeEnd = reached && (next < length)
        if (reachedBeforeEnd
                        && isWithSmartTruncation
                        && ((!isSpace(origine.codePointAt(current)) && !isSpace(origine.codePointAt(next))) 
                                        || isSpace(origine.codePointAt(current)))) {
            val smartLentgh = new String(Arrays.copyOfRange(ch, start, start + next)).replaceFirst(TRUNCATED_LAST_WORD,
                            EMPTY_STRING).length
            next = smartLentgh
        }
        super.characters(ch, start, next)
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " Unicode code points (characters), and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag)
    }

    private def void countingByWord(char[] ch, int start, int length) 
    throws SAXException {
        val origine = new String(Arrays.copyOfRange(ch, start, start + length))
        if (writeLimit == NO_LIMIT || length == 0) {
            super.characters(ch, start, length)
            val splitted = origine.split(SPACES_PATTERN)
            if (splitted.length > 0) {
                writeCount += splitted.length + if(splitted.get(0).isEmpty) -1 else 0
            }
            return
        }
        
        val splitted = origine.split(String.format(WITH_DELIMITER_SPLITTER_PATTERN, SPACE_PATTERN))
        val result = new StringBuilder
        var reachedBeforeEnd = false
        for (var i = 0; ! reachedBeforeEnd && i < splitted.length; i++) {
            val token = splitted.get(i)
            val count = writeCount + if(isSpace(token.codePointAt(0))) 0 else 1
            if (count > writeLimit) {
                reachedBeforeEnd = true
            } else {
                writeCount = count
                result.append(token)
            }
        }
        
        val size = if(!reachedBeforeEnd) result.length
                    else result.toString.replaceFirst(SPACES_TAIL, EMPTY_STRING).length
        super.characters(ch, start, size)
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " words, and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag)
    }

    override void ignorableWhitespace(char[] ch, int start, int length) 
    throws SAXException {
        val counting = isCountingWithSpaces && isCountingWithAllSpaces && (getUnit != Unit.word)
        var writeCountInc = if(counting) length else 0
        var next = length
        if (writeLimit == NO_LIMIT || !counting) {
            super.ignorableWhitespace(ch, start, next)
            writeCount += writeCountInc
            return
        }
        val reachedBeforeEnd = writeCount + writeCountInc > writeLimit;
        if (reachedBeforeEnd) {
            writeCountInc = writeLimit - writeCount
            next = writeCountInc
        }
        writeCount += writeCountInc
        super.ignorableWhitespace(ch, start, next)
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + unit.name() + "s, and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag)

    }

    /**
     * Checks whether the given exception (or any of it's root causes) was
     * thrown by this handler as a signal of reaching the write limit.
     *
     * @param t
     *            throwable
     * @return <code>true</code> if the write limit was reached,
     *         <code>false</code> otherwise
     */
    def boolean isWriteLimitReached(Throwable t) {
        if (t instanceof WriteLimitReachedException) {
            tag == t.tag // (t as WriteLimitReachedException).tag
        } else {
            (t.cause !== null) && isWriteLimitReached(t.cause)
        }
    }

    /**
     * The exception used as a signal when the write limit has been reached.
     */
    private static class WriteLimitReachedException extends SAXException {

        /** Serializable tag of the handler that caused this exception */
        val Serializable tag

        new(String message, Serializable tag) {
            super(message)
            this.tag = tag
        }

    }

    /*
     * is equivalent to the regex [\\p{javaWhitespace}\\p{Z}] defined by SPACE_PATTERN_BASE
     * 
     * \p{Z} will catch the no break space, i.e.: NO-BREAK SPACE (U+00A0),
     * NARROW NO-BREAK SPACE (U+202F), ...
     */
    private def static isSpace(char c) {
        Character.isWhitespace(c) || Character.isSpaceChar(c)
    }

    private def static isSpace(int c) {
        Character.isWhitespace(c) || Character.isSpaceChar(c)
    }

}
