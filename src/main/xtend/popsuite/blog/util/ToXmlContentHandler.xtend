package popsuite.blog.util

import org.apache.tika.sax.ToXMLContentHandler

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
 * SAX event handler that serializes the XML document to a character stream.
 * The incoming SAX events are expected to be well-formed (properly nested,
 * etc.) and to explicitly include namespace declaration and corresponding
 * namespace prefixes in element and attribute names. This classe is based on
 * {@link ToXMLContentHandler} This implementation doesn't
 * rely on {@link ToTextContentHandler#characters} to write in the buffer. So
 * {@link TruncateContentHandler} can be redefined with other counting modes
 * (without spaces, by word,...).
 */
class ToXmlContentHandler extends ToTextContentHandler {

    val static XML_ENCODING_PATTERN = "<?xml version=\"1.0\" encoding=\"%s\" ?>\n"
    val static ATTRIBUTE_PATTERN    = " %s=\"%s\""
    val static CHARS_ENTITY_PATTERN = "%s&%s;"

    private static class ElementInfo {

        val ElementInfo         parent

        val Map<String, String> namespaces

        val String              qname

        new(ElementInfo parent, Map<String, String> namespaces, String uri, String localName) 
        throws SAXException {
            this.parent = parent
            this.namespaces = if (namespaces.isEmpty) Collections.emptyMap else new HashMap(namespaces)
            qname = getQName(uri, localName)
        }

        def String getPrefix(String uri) 
        throws SAXException {
            val prefix = namespaces.get(uri)
            if (prefix !== null) {
                prefix
            } else if (parent !== null) {
                parent.getPrefix(uri)
            } else if (uri === null || uri.length == 0) {
                ""
            } else {
                throw new SAXException(format("Namespace %s not declared", uri))
            }
        }

        def getQName(String uri, String localName) 
        throws SAXException {
            val prefix = getPrefix(uri)
            if (prefix.length > 0) {
                prefix + ":" + localName
            } else {
                localName
            }
        }

        def getQName() {
            qname
        }

    }

    val Writer                writer
    val Charset               encoding
    protected val             namespaces     = new HashMap<String, String>

    protected var             inStartElement = false
    var ElementInfo           currentElement = null

    new(Writer writer) {
        super(writer)
        this.writer = writer
        this.encoding = null
    }

    new(OutputStream stream, Charset encoding) 
    throws UnsupportedEncodingException {
        this(new OutputStreamWriter(stream, encoding), encoding)
    }

    private new(Writer writer, Charset encoding) {
        super(writer)
        this.writer = writer
        this.encoding = encoding
    }

    protected def getCurrentElementName() {
        currentElement.getQName
    }

    private def void setCurrentElement(ElementInfo info) {
        currentElement = info
    }

    private def getCurrentElement() {
        currentElement
    }

    override void startDocument() 
    throws SAXException {
        if (encoding !== null) {
            write(format(XML_ENCODING_PATTERN, encoding))
        }

        setCurrentElement(null)
        namespaces.clear
    }

    override void startPrefixMapping(String prefix, String uri) 
    throws SAXException {
        try {
            if (getCurrentElement !== null && prefix == getCurrentElement.getPrefix(uri)) {
                return
            }
        } catch (SAXException ignore) {
        }
        namespaces.put(uri, prefix)
    }

    override void startElement(String uri, String localName, String qName, Attributes atts) 
    throws SAXException {
        lazyCloseStartElement

        setCurrentElement(new ElementInfo(getCurrentElement, namespaces, uri, localName))

        write('<')
        write(getCurrentElement.getQName)

        for (var i = 0; i < atts.length; i++) {
            val name = getCurrentElement.getQName(atts.getURI(i), atts.getLocalName(i))
            writeAttribute(name, atts.getValue(i))
        }

        for (entry : namespaces.entrySet) {
            val prefix = entry.value
            val name = "xmlns" + if (prefix.isEmpty) "" else (":" + prefix)
            writeAttribute(name, entry.key)
        }
        namespaces.clear

        inStartElement = true
    }

    private def void writeAttribute(String name, String value) 
    throws SAXException {
        val ch = value.toCharArray
        val sb = editEscaped(ch, 0, ch.length, true)
        write(format(ATTRIBUTE_PATTERN, name, sb))
    }

    override void endElement(String uri, String localName, String qName) 
    throws SAXException {
        if (! lazyCloseStartElement) {
            write("</")
            write(qName) // ??? getCurrentElement().getQName() ???
            write('>')
        }

        namespaces.clear

        // Reset the position in the tree, to avoid endless stack overflow
        // chains (see TIKA-1070)
        setCurrentElement(getCurrentElement.parent)
    }

    override void characters(char[] ch, int start, int length) 
    throws SAXException {
        writeWithLazyClosing(ch, start, length)
    }

    override void ignorableWhitespace(char[] ch, int start, int length) 
    throws SAXException {
        writeWithLazyClosing(ch, start, length)
    }

    private def boolean lazyCloseStartElement() 
    throws SAXException {
        if (inStartElement) {
            write('>')
            inStartElement = false
        }
        inStartElement
    }

    private def void writeWithLazyClosing(char[] ch, int start, int length) 
    throws SAXException {
        lazyCloseStartElement
        writeEscaped(ch, start, start + length, false)
    }

    protected def void write(char[] ch, int start, int length) 
    throws SAXException {
        try {
            writer.write(ch, start, length)
        } catch (IOException e) {
            throw new SAXException(format("Error writing: %s", new String(ch, start, length)), e)
        }
    }

    protected def void write(char ch) 
    throws SAXException {
        write(#[ch], 0, 1)
    }

    protected def void write(CharSequence string) 
    throws SAXException {
        write(string.toString.toCharArray, 0, string.length)
    }

    private def editCharsAndEntity(char[] ch, int from, int to, String entity) {
        format(CHARS_ENTITY_PATTERN, new String(Arrays.copyOfRange(ch, from, to)), entity)
    }

    private def StringBuilder editEscaped(char[] ch, int from, int to, boolean attribute) {
        val buffer = new StringBuilder
        var pos = from
        var f = from
        while (pos < to) {

            val ref = CharacterEntityReference.findByWithCondition(ch.get(pos), attribute)
            if (ref !== null) {
                buffer.append(editCharsAndEntity(ch, f, pos, ref.name))
                pos++
                f = pos
            } else {
                pos++
            }

        }
        buffer.append(Arrays.copyOfRange(ch, from, to))
    }

    private def void writeEscaped(char[] ch, int from, int to, boolean attribute) 
    throws SAXException {
        write(editEscaped(ch, from, to, attribute))
    }

}
