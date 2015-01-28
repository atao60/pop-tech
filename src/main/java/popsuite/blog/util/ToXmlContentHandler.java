package popsuite.blog.util;

import static java.lang.String.format;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.apache.tika.sax.ToTextContentHandler;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

/**
 * SAX event handler that serialisezes the XML document to a character stream.
 * The incoming SAX events are expected to be well-formed (properly nested,
 * etc.) and to explicitly include namespace declaration and corresponding
 * namespace prefixes in element and attribute names. This classe is based on
 * {@link org.apache.tika.sax.ToXMLContentHandler} This implementation doesn't
 * rely on {@link ToTextContentHandler#characters} to write in the buffer. So
 * {@link TruncateContentHandler} can be redefined with other counting modes
 * (without spaces, by word,...).
 */
public class ToXmlContentHandler extends ToTextContentHandler {

    private static final String XML_ENCODING_PATTERN = "<?xml version=\"1.0\" encoding=\"%s\" ?>\n";
    private static final String ATTRIBUTE_PATTERN    = " %s=\"%s\"";
    private static final String CHARS_ENTITY_PATTERN = "%s&%s;";

    private enum CharacterEntityReference {
        lt('<'), gt('>'), amp('&'), quot('"', true);
        private final char    character;
        private final boolean conditional;

        private CharacterEntityReference(final char ref) {
            this(ref, false);
        }

        private CharacterEntityReference(final char ref, final boolean conditional) {
            this.character = ref;
            this.conditional = conditional;
        }

        public static CharacterEntityReference findByWithCondition(char ref, boolean condition) {
            for (CharacterEntityReference r : CharacterEntityReference.values()) {
                if (r.character == ref)
                    return (!r.conditional || condition) ? r : null;
            }
            return null;
        }
    }

    private static class ElementInfo {

        private final ElementInfo         parent;

        private final Map<String, String> namespaces;

        private final String              qname;

        public ElementInfo(final ElementInfo parent, final Map<String, String> namespaces, final String uri,
                        final String localName) throws SAXException {
            this.parent = parent;
            if (namespaces.isEmpty()) {
                this.namespaces = Collections.emptyMap();
            } else {
                this.namespaces = new HashMap<String, String>(namespaces);
            }
            qname = getQName(uri, localName);
        }

        public String getPrefix(final String uri) throws SAXException {
            String prefix = namespaces.get(uri);
            if (prefix != null) {
                return prefix;
            } else if (parent != null) {
                return parent.getPrefix(uri);
            } else if (uri == null || uri.length() == 0) {
                return "";
            } else {
                throw new SAXException(format("Namespace %s not declared", uri));
            }
        }

        public String getQName(final String uri, final String localName) throws SAXException {
            String prefix = getPrefix(uri);
            if (prefix.length() > 0) {
                return prefix + ":" + localName;
            } else {
                return localName;
            }
        }

        public String getQName() {
            return qname;
        }

    }

    private final Writer                writer;
    private final Charset               encoding;
    protected final Map<String, String> namespaces     = new HashMap<String, String>();

    protected boolean                   inStartElement = false;
    private ElementInfo                 currentElement = null;

    public ToXmlContentHandler(final Writer writer) {
        super(writer);
        this.writer = writer;
        this.encoding = null;
    }

    public ToXmlContentHandler(final OutputStream stream, final Charset encoding) throws UnsupportedEncodingException {
        this(new OutputStreamWriter(stream, encoding), encoding);
    }

    private ToXmlContentHandler(Writer writer, Charset encoding) {
        super(writer);
        this.writer = writer;
        this.encoding = encoding;
    }

    protected String getCurrentElementName() {
        return currentElement.getQName();
    }

    private void setCurrentElement(ElementInfo info) {
        currentElement = info;
    }

    private ElementInfo getCurrentElement() {
        return currentElement;
    }

    @Override
    public void startDocument() throws SAXException {
        if (encoding != null) {
            write(format(XML_ENCODING_PATTERN, encoding));
        }

        setCurrentElement(null);
        namespaces.clear();
    }

    @Override
    public void startPrefixMapping(final String prefix, final String uri) throws SAXException {
        try {
            if (getCurrentElement() != null && prefix.equals(getCurrentElement().getPrefix(uri))) {
                return;
            }
        } catch (SAXException ignore) {
        }
        namespaces.put(uri, prefix);
    }

    @Override
    public void startElement(final String uri, final String localName, final String qName, final Attributes atts) throws SAXException {
        lazyCloseStartElement();

        setCurrentElement(new ElementInfo(getCurrentElement(), namespaces, uri, localName));

        write('<');
        write(getCurrentElement().getQName());

        for (int i = 0; i < atts.getLength(); i++) {
            String name = getCurrentElement().getQName(atts.getURI(i), atts.getLocalName(i));
            writeAttribute(name, atts.getValue(i));
        }

        for (Map.Entry<String, String> entry : namespaces.entrySet()) {
            String prefix = entry.getValue();
            String name = "xmlns" + (prefix.isEmpty() ? "" : ":" + prefix);
            writeAttribute(name, entry.getKey());
        }
        namespaces.clear();

        inStartElement = true;
    }

    private void writeAttribute(String name, String value) throws SAXException {
        char[] ch = value.toCharArray();
        StringBuilder sb = editEscaped(ch, 0, ch.length, true);
        write(format(ATTRIBUTE_PATTERN, name, sb));
    }

    @Override
    public void endElement(final String uri, final String localName, final String qName) throws SAXException {
        if (! lazyCloseStartElement()) {
            write("</");
            write(qName); // ??? getCurrentElement().getQName() ???
            write('>');
        }

        namespaces.clear();

        // Reset the position in the tree, to avoid endless stack overflow
        // chains (see TIKA-1070)
        setCurrentElement(getCurrentElement().parent);
    }

    @Override
    public void characters(final char[] ch, final int start, final int length) throws SAXException {
        writeWithLazyClosing(ch, start, length);
    }

    @Override
    public void ignorableWhitespace(final char[] ch, final int start, final int length) throws SAXException {
        writeWithLazyClosing(ch, start, length);
    }

    private boolean lazyCloseStartElement() throws SAXException {
        if (inStartElement) {
            write('>');
            inStartElement = false;
        }
        return inStartElement;
    }

    private void writeWithLazyClosing(char[] ch, int start, int length) throws SAXException {
        lazyCloseStartElement();
        writeEscaped(ch, start, start + length, false);
    }

    protected void write(final char[] ch, final int start, final int length) throws SAXException {
        try {
            writer.write(ch, start, length);
        } catch (IOException e) {
            throw new SAXException(format("Error writing: %s", new String(ch, start, length)), e);
        }
    }

    protected void write(final char ch) throws SAXException {
        write(new char[] { ch }, 0, 1);
    }

    protected void write(final CharSequence string) throws SAXException {
        write(string.toString().toCharArray(), 0, string.length());
    }

    private String editCharsAndEntity(char[] ch, int from, int to, String entity) {
        return format(CHARS_ENTITY_PATTERN, new String(Arrays.copyOfRange(ch, from, to)), entity);
    }

    private StringBuilder editEscaped(char[] ch, int from, int to, boolean attribute) {
        StringBuilder buffer = new StringBuilder();
        int pos = from;
        while (pos < to) {

            CharacterEntityReference ref = CharacterEntityReference.findByWithCondition(ch[pos], attribute);
            if (ref != null) {
                buffer.append(editCharsAndEntity(ch, from, pos, ref.name()));
                from = ++pos;
            } else {
                pos++;
            }

        }
        return buffer.append(Arrays.copyOfRange(ch, from, to));
    }

    private void writeEscaped(char[] ch, int from, int to, boolean attribute) throws SAXException {
        write(editEscaped(ch, from, to, attribute));
    }

}
