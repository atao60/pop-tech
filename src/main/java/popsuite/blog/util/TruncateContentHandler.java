package popsuite.blog.util;

import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Serializable;
import java.io.StringWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.UUID;

import org.apache.tika.sax.ContentHandlerDecorator;
import org.apache.tika.sax.ToTextContentHandler;
import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;

/**
 * SAX event handler that writes content up to an optional limit to a character stream or other decorated handler.
 * This classe is based on {@link org.apache.tika.sax.WriteOutContentHandler} with some improvements.
 * The counter is now accessible by any derived classe. It's also possible to chose:
 * <li>the type of item to count: characters, Unicode code points or words</li>
 * <li>when counting characters or code points, if spaces has to be counted or not</li>
 * <li>when counting characters or code points, if the last word can be splitted or not</li>
 * 
 * Required {@link ToXmlContentHandler}: it doesn't work with the original {@link  org.apache.tika.sax.ToXMLContentHandler}. 
 */
public class TruncateContentHandler extends ContentHandlerDecorator {

    public enum Unit {
        word, codePoint, character
    }
    
    public  static final int    NO_LIMIT            = -1;
    private static final int    DEFAULT_LIMIT       = 100 * 1000;
    private static final Unit   DEFAULT_UNIT        = Unit.character;

    private static final String EMPTY_STRING        = "";
    /* SPACE_PATTERN_BASE must be defined in accordance with the method {@link #isSpace} for Unicode Cope Point */
    public static final String SPACE_PATTERN_BASE  = "\\p{javaWhitespace}\\p{Z}";
    private static final String SPACE_PATTERN       = "[" + SPACE_PATTERN_BASE + "]";
    private static final String SPACES_PATTERN      = SPACE_PATTERN + "+";
    private static final String NO_SPACE_PATTERN    = "[^" + SPACE_PATTERN_BASE + "]";
    private static final String TRUNCATED_LAST_WORD = "(?s)" + SPACES_PATTERN + NO_SPACE_PATTERN + "*$";
    private static final String WITH_DELIMITER_SPLITTER_PATTERN = "(?=(?!^)%1$s)(?<!%1$s)|(?!%1$s)(?<=%1$s)";
    private static final String SPACES_TAIL         = "(?s)" + SPACES_PATTERN + "$";

    private boolean             withSpaces          = true;
    /* even with LF, FF, ... */
    private boolean             withAllSpaces       = false;
    private boolean             withSmartTruncation = true;
    private Unit                unit                = DEFAULT_UNIT;

    /**
     * The unique tag associated with exceptions from stream.
     */
    private final Serializable  tag                 = UUID.randomUUID();

    /**
     * The maximum number of characters to write to the character stream. Set to
     * -1 for no limit.
     */
    private final int           writeLimit;

    /**
     * Number of characters written so far.
     */
    private int                 writeCount          = 0;

    /**
     * Creates a content handler that writes content up to the given write limit
     * to the given content handler.
     *
     * @param handler
     *            content handler to be decorated
     * @param writeLimit
     *            write limit
     */
    public TruncateContentHandler(ContentHandler handler, int writeLimit) {
        super(handler);
        if (writeLimit < NO_LIMIT)
            throw new IllegalArgumentException("Either no limit (-1), zero or positive number as limit.");
        this.writeLimit = writeLimit;
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
    public TruncateContentHandler(Writer writer, int writeLimit) {
        this(new ToTextContentHandler(writer), writeLimit);
    }

    /**
     * Creates a content handler that writes character events to the given
     * writer.
     *
     * @param writer
     *            writer
     */
    public TruncateContentHandler(Writer writer) {
        this(writer, NO_LIMIT);
    }

    /**
     * Creates a content handler that writes character events to the given
     * output stream using the default encoding.
     *
     * @param stream
     *            output stream
     */
    public TruncateContentHandler(OutputStream stream) {
        this(new OutputStreamWriter(stream, Charset.defaultCharset()));
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
    public TruncateContentHandler(int writeLimit) {
        this(new StringWriter(), writeLimit);
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
    public TruncateContentHandler() {
        this(DEFAULT_LIMIT);
    }

    protected int getWriteLimit() {
        return writeLimit;
    }

    protected boolean isWriteLimitReached() {
        return writeLimit != NO_LIMIT && writeLimit < writeCount;
    }

    public boolean isCountingWithSpaces() {
        return withSpaces;
    }

    public void setCountingWithSpaces(boolean withSpaces) {
        this.withSpaces = withSpaces;
    }

    public boolean isCountingWithAllSpaces() {
        return withAllSpaces;
    }

    public void setCountingWithAllSpaces(boolean withSpaces) {
        this.withAllSpaces = withSpaces;
    }

    public boolean isWithSmartTruncation() {
        return withSmartTruncation;
    }

    public void setWithSmartTruncation(boolean smart) {
        this.withSmartTruncation = smart;
    }

    public Unit getUnit() {
        return unit;
    }

    public void setUnit(Unit unit) {
        this.unit = unit;
    }

    /**
     * Writes the given characters to the given character stream.
     */
    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        if (unit == Unit.character) {
            countingByCharacter(ch, start, length);
        } else if (unit == Unit.codePoint) {
            countingByCodePoint(ch, start, length);
        } else {
            countingByWord(ch, start, length);
        }
    }

    private void countingByCharacter(char[] ch, int start, int length) throws SAXException {
        if (writeLimit == NO_LIMIT) {
            super.characters(ch, start, length);
            String origine = new String(Arrays.copyOfRange(ch, start, start + length));
            String stripped = isCountingWithSpaces() ? origine : origine.replaceAll(SPACES_PATTERN, EMPTY_STRING);
            writeCount += stripped.length();
            return;
        }

        boolean reached = false;
        int next = start;
        for (int i = start; i < start + length; i++) {
            next = i + 1;
            if (!isCountingWithSpaces() && isSpace(ch[i]))
                continue;

            writeCount++;
            if (writeCount < writeLimit)
                continue;
            
            reached = true;
            break;
        }
        boolean reachedBeforeEnd = reached && (next < start + length);
        if (reachedBeforeEnd && isWithSmartTruncation()
                        && ((!isSpace(ch[next - 1]) && !isSpace(ch[next])) || isSpace(ch[next - 1]))) {
            int smartLentgh = new String(Arrays.copyOfRange(ch, start, next)).replaceFirst(TRUNCATED_LAST_WORD,
                            EMPTY_STRING).length();
            next = start + smartLentgh;
        }
        super.characters(ch, start, next - start);
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " Unicode unit points (characters), and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag);

    }

    private void countingByCodePoint(char[] ch, int start, int length) throws SAXException {
        String origine = new String(Arrays.copyOfRange(ch, start, start + length));
        if (writeLimit == NO_LIMIT || length == 0) {
            super.characters(ch, start, length);
            String stripped = isCountingWithSpaces() ? origine : origine.replaceAll(SPACES_PATTERN, EMPTY_STRING);
            writeCount += stripped.codePointCount(0, stripped.length());
            return;
        }

        boolean reached = false;
        int next = 0;
        int current = 0;
        for (int i = 0; i < origine.codePointCount(0, origine.length()); i++) {
            current = origine.offsetByCodePoints(0, i);
            int currentCodePoint = origine.codePointAt(current);
            next = current + Character.charCount(currentCodePoint);
            if (!isCountingWithSpaces() && isSpace(currentCodePoint))
                continue;

            writeCount++;
            if (writeCount < writeLimit)
                continue;
            reached = true;
            break;
        }
        boolean reachedBeforeEnd = reached && (next < length);
        if (reachedBeforeEnd
                        && isWithSmartTruncation()
                        && ((!isSpace(origine.codePointAt(current)) && !isSpace(origine.codePointAt(next))) 
                                        || isSpace(origine.codePointAt(current)))) {
            int smartLentgh = new String(Arrays.copyOfRange(ch, start, start + next)).replaceFirst(TRUNCATED_LAST_WORD,
                            EMPTY_STRING).length();
            next = smartLentgh;
        }
        super.characters(ch, start, next);
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " Unicode code points (characters), and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag);
    }

    private void countingByWord(char[] ch, int start, int length) throws SAXException {
        String origine = new String(Arrays.copyOfRange(ch, start, start + length));
        if (writeLimit == NO_LIMIT || length == 0) {
            super.characters(ch, start, length);
            String[] splitted = origine.split(SPACES_PATTERN);
            if (splitted.length > 0) {
                writeCount += splitted.length + (splitted[0].isEmpty() ? -1 : 0);
            }
            return;
        }
        
        String[] splitted = origine.split(String.format(WITH_DELIMITER_SPLITTER_PATTERN, SPACE_PATTERN));
        StringBuilder result = new StringBuilder();
        boolean reachedBeforeEnd = false;
        for(String token:splitted) {
            int count = writeCount + (isSpace(token.codePointAt(0)) ? 0 : 1);
            if (count > writeLimit) {
                reachedBeforeEnd = true;
                break;
            }
            writeCount = count;
            result.append(token);
        }
        
        int size = !reachedBeforeEnd ? result.length() : result.toString().replaceFirst(SPACES_TAIL, EMPTY_STRING).length();
        super.characters(ch, start, size);
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + " words, and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag);
    }

    @Override
    public void ignorableWhitespace(char[] ch, int start, int length) throws SAXException {
        boolean counting = isCountingWithSpaces() && isCountingWithAllSpaces() && (getUnit() != Unit.word);
        int writeCountInc = counting ? length : 0;
        int next = length;
        if (writeLimit == NO_LIMIT || !counting) {
            super.ignorableWhitespace(ch, start, next);
            writeCount += writeCountInc;
            return;
        }
        boolean reachedBeforeEnd = writeCount + writeCountInc > writeLimit;
        if (reachedBeforeEnd) {
            writeCountInc = writeLimit - writeCount;
            next = writeCountInc;
        }
        writeCount += writeCountInc;
        super.ignorableWhitespace(ch, start, next);
        if (reachedBeforeEnd)
            throw new WriteLimitReachedException("Your document contained more than " + writeLimit
                            + unit.name() + "s, and so your requested limit has been"
                            + " reached. To receive the full text of the document,"
                            + " increase your limit. (Text up to the limit is" + " however available).", tag);

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
    public boolean isWriteLimitReached(Throwable t) {
        if (t instanceof WriteLimitReachedException) {
            return tag.equals(((WriteLimitReachedException) t).tag);
        } else {
            return t.getCause() != null && isWriteLimitReached(t.getCause());
        }
    }

    /**
     * The exception used as a signal when the write limit has been reached.
     */
    private static class WriteLimitReachedException extends SAXException {

        /** Serial version UID */
        private static final long  serialVersionUID = -1850581945459429943L;

        /** Serializable tag of the handler that caused this exception */
        private final Serializable tag;

        public WriteLimitReachedException(String message, Serializable tag) {
            super(message);
            this.tag = tag;
        }

    }

    /*
     * is equivalent to the regex [\\p{javaWhitespace}\\p{Z}] defined by SPACE_PATTERN_BASE
     * 
     * \p{Z} will catch the no break space, i.e.: NO-BREAK SPACE (U+00A0),
     * NARROW NO-BREAK SPACE (U+202F), ...
     */
    private static boolean isSpace(char c) {
        return Character.isWhitespace(c) || Character.isSpaceChar(c);
    }

    private static boolean isSpace(int c) {
        return Character.isWhitespace(c) || Character.isSpaceChar(c);
    }

}
