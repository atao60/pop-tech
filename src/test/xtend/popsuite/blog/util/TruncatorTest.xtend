package popsuite.blog.util

import static org.apache.commons.lang3.StringEscapeUtils.unescapeHtml4
import static org.hamcrest.MatcherAssert.assertThat
import static org.hamcrest.Matchers.*

import java.nio.charset.Charset
import java.nio.charset.StandardCharsets

import org.junit.Test

//import popsuite.blog.util.Truncate
import popsuite.blog.util.TruncateContentHandler.Unit

/*
 * TODO: add tests with readmore
 */
class TruncatorTest {

    val static HTML_DOC = String.join(System.lineSeparator(),
"<p>Faire un blog sur mes pérégrinations informatiques me trottait dans la tête depuis un certain temps. Histoire d&rsquo;en conserver une trace. Et si en plus cela pouvait servir à d&rsquo;autres&hellip;</p><p>Après avoir installé un <a href='http://atao60.github.io/maven-site-demo/'>site javadoc</a> de démonstration sur <a href='https://github.com/'>Github</a> à l&rsquo;aide de <a href='http://maven.apache.org/'>Maven</a>, la possibilité de créer un blog sur le même principe est devenue incontournable. Le temps de faire le lien avec <a href='http://jekyllrb.com/'>Jekyll</a> puis <a href='http://jbake.org/'>JBake</a>&nbsp;!</p><p>Le choix de <a href='http://jbake.org/'>JBake</a> permet de rester dans un cadre 100% JVM.</p><p>Trois articles ont fourni les bases&nbsp;:</p>",
"<ul>",
"  <li><p><a href='http://melix.github.io/blog/2014/02/hosting-jbake-github.html'>Authoring your blog on GitHub with JBake and Gradle</a><br/>Cédric Champeau, 3/2/14</p></li>",
"  <li><p><a href='http://www.ybonnel.fr/tags/jbake.html'>Migration de blogger à jbake</a><br/>Yan Bonnel, 2/7/14</p></li>",
"  <li><p><a href='http://docs.ingenieux.com.br/project/jbake/walkthrough.html'>JBake Maven Plugin Walkthough</a> </p></li>",
"</ul><p>N&rsquo;ayant jamais utilisé <a href='https://www.gradle.org/'>Gradle</a>, j&rsquo;ai opté pour <a href='http://maven.apache.org/'>Maven</a> avec l&rsquo;extension <a href='https://github.com/ingenieux/jbake-maven-plugin'>jbake-maven-plugin</a>. Yan Bonnel fournit dans son billet toutes les informations pour se lancer. D&rsquo;autant qu&rsquo;il met aussi à disposition le <a href='http://github.com/ybonnel/blog'>code</a> de son propre blog <a href='http://www.ybonnel.fr/'>JustAnOtherDevBlog</a>. Et pour rendre à César&hellip; Cédric Champeau fait <a href='https://github.com/melix/blog'>de même</a> pour son <a href='http://melix.github.io/blog/'>Blog</a> .</p><p>Ne reste plus qu&rsquo;à tester&nbsp;:</p>",
"<ul>",
"  <li>la répercussion en temps réel des modifications sur l&rsquo;affichage du blog grâce à <a href='http://livereload.com/'>livereload</a> qui est intégrée à <a href='https://github.com/ingenieux/jbake-maven-plugin'>jbake-maven-plugin</a>,</li>",
"  <li>le transfert du blog vers <a href='https://github.com/'>Github</a> à l&rsquo;aide de <a href='https://github.com/github/maven-plugins'>Github site plugin</a>.</li>",
"</ul><p>Ce qui aurait dû rester une promenade de santé s&rsquo;est avéré un parcours du combattant. </p><p>Commençons avec <a href='http://livereload.com/'>livereload</a>&nbsp;: dès qu&rsquo;une modification est enregistrée, <a href='https://github.com/ingenieux/jbake-maven-plugin/issues/6'>livereload s&rsquo;arrête</a>. Pour le moment, il faut travailler avec un <a href='https://github.com/atao60/jbake-maven-plugin'>fork</a> de la version 0.0.9-SNAPSHOT.</p><p>Et les déboires continuent avec <a href='https://github.com/github/maven-plugins'>Github site plugin</a>&nbsp;:</p>",
"<ul>",
"  <li><p>la version 0.9 bloque avec des messages abscons, cf.&nbsp;<a href='https://github.com/github/maven-plugins/issues/69'>Error creating commit: Invalid request #69</a>,</p></li>",
"  <li><p>le passage à la version 0.10 requiert une bibliothèque qui n&rsquo;est pas disponible sur Maven Central, cf.&nbsp;<a href='https://github.com/github/maven-plugins/issues/74'>artifact egit.github.core 3.1.0.201310021548-r not available on maven central #74</a>,</p></li>",
"  <li><p>et reste au final que l&rsquo;API de <a href='https://github.com/github/maven-plugins'>Github site plugin</a> a changé&nbsp;: elle requiert maintenant que le nom et l&rsquo;email du compte <a href='https://github.com/'>Github</a> soient renseignés, cf.&nbsp;<a href='https://github.com/github/maven-plugins/issues/77'>Error deploying when email address not public #77</a>.</p></li>",
"</ul><p>Pourquoi pas de fournir un nom, mais aucune envie d&rsquo;une adresse email qui soit rendue publique.</p><p>Ne reste donc qu&rsquo;à remplacer <a href='https://github.com/github/maven-plugins'>Github site plugin</a> par <a href='http://maven.apache.org/plugins/maven-scm-publish-plugin/'>maven-scm-publish-plugin</a>.</p><p>Ah, quel plaisir d&rsquo;avoir enfin son petit blog perso. Et cerise sur le gâteau&nbsp;: <a href='https://github.com/'>Github</a> permet de publier un tel site avec son propre nom de domaine.</p><p>Le dépôt Github du blog est disponible <a href='https://github.com/atao60/pop-tech'>ici</a>.</p><p>Dans une série de billets à venir, je donnerai plus de détail pour arriver à ce résultat. À bientôt.</p>"
            )
    
    val static SIXTY_WORDS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur mes pérégrinations informatiques me trottait dans la tête depuis un certain temps. Histoire d&rsquo;en conserver une trace. Et si en plus cela pouvait servir à d&rsquo;autres&hellip;</p><p>Après avoir installé un <a href='http://atao60.github.io/maven-site-demo/'>site javadoc</a> de démonstration sur <a href='https://github.com/'>Github</a> à l&rsquo;aide de <a href='http://maven.apache.org/'>Maven</a>, la possibilité de créer un blog sur le même principe est...</p>"
                    ))
    val static TWENTY_WORDS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur mes pérégrinations informatiques me trottait dans la tête depuis un certain temps. Histoire d&rsquo;en conserver...</p>"
                    ))
    val static TWENTY_SPACES_AND_CHARS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur...</p>"
                    ))
    val static TWENTY_CHARS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur mes...</p>"
                    ))
    val static STRICT_TWENTY_SPACES_AND_CHARS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur me...</p>"
                    ))
    val static STRICT_TWENTY_CHARS_HTML_DOC = unescapeHtml4(String.join(System.lineSeparator(),
                    "<p>Faire un blog sur mes pér...</p>"
                    ))

//    val static           DEFAULT_LIMIT                              = 60
    val static Charset   DEFAULT_CHARSET                            = StandardCharsets.UTF_8
//    val static           DEFAULT_UNIT                               = Unit.word
    val static           DEFAULT_ELLIPSIS                           = "..."
    val static           NEW_ELLIPSIS                               = "[...]"
    
    @Test
    def testDefaultConstructor() 
    throws Exception {
        var result = new Truncator().source(HTML_DOC).run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(SIXTY_WORDS_HTML_DOC))
    }

    /*
     * Any spaces and elision apostrophe are separators.
     */
    @Test
    def testWithDefaultWordLimitConstructor() 
    throws Exception {
        val limit = 20
        var result = new Truncator(limit).source(HTML_DOC).run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(TWENTY_WORDS_HTML_DOC))
        assertThat(result.split("\\s+|(?<=[j|t|d|l|u|s|n|m])" + Truncator.FRENCH_ELISION).length, equalTo(limit))
    }

    @Test
    def testDefaultEllipsis() 
    throws Exception {
        var result = new Truncator(20).source(HTML_DOC).run
        result = removeTagSoupArtifacts(result)
        result = removeAllHtmlTags(result)
        assertThat(result.substring(result.length - DEFAULT_ELLIPSIS.length, result.length), equalTo(DEFAULT_ELLIPSIS))
    }

    @Test
    def testNewEllipsis() 
    throws Exception {
        val truncator = new Truncator(20).source(HTML_DOC)
        var result = truncator.ellipsis(NEW_ELLIPSIS).run
        result = removeTagSoupArtifacts(result)
        result = removeAllHtmlTags(result)
        assertThat(result.substring(result.length - NEW_ELLIPSIS.length, result.length), equalTo(NEW_ELLIPSIS))
    }

    @Test
    def testWithCharLimitConstructor() 
    throws Exception {
        val limit = 20
        var truncator = new Truncator(Unit.character, limit, DEFAULT_CHARSET).source(HTML_DOC)
        var result = truncator.run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(TWENTY_CHARS_HTML_DOC))
        result = removeAllSpaces(removeEllipsis(removeAllHtmlTags(result), DEFAULT_ELLIPSIS))
        assertThat(result.length, lessThanOrEqualTo(limit))
    }
    
    @Test
    def testWithSpaceAndCharLimitConstructor() 
    throws Exception {
        val limit = 20
        val truncator = new Truncator(Unit.character, limit, DEFAULT_CHARSET).source(HTML_DOC)
        var result = truncator.countingWithSpaces(true).run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(TWENTY_SPACES_AND_CHARS_HTML_DOC))
        result = removeEllipsis(removeAllHtmlTags(result), DEFAULT_ELLIPSIS)
        assertThat(result.length, lessThanOrEqualTo(limit))
    }
    
    @Test
    def testWithStrictCharLimitConstructor() 
    throws Exception {
        val limit = 20;
        val truncator = new Truncator(Unit.character, limit, DEFAULT_CHARSET).source(HTML_DOC)
        var result = truncator.smartTruncation(false).run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(STRICT_TWENTY_CHARS_HTML_DOC))
        result = removeAllSpaces(removeEllipsis(removeAllHtmlTags(result), DEFAULT_ELLIPSIS))
        assertThat(result.length, equalTo(limit))
    }
    
    @Test
    def testWithStrictSpaceAndCharLimitConstructor() 
    throws Exception {
        val limit = 20
        val truncator = new Truncator(Unit.character, limit, DEFAULT_CHARSET).source(HTML_DOC)
        var result = truncator.smartTruncation(false).countingWithSpaces(true).run
        result = removeTagSoupArtifacts(result)
        assertThat(result, equalTo(STRICT_TWENTY_SPACES_AND_CHARS_HTML_DOC))
        result = removeEllipsis(removeAllHtmlTags(result), DEFAULT_ELLIPSIS)
        assertThat(result.length, equalTo(limit))
    }
    
    /*
     * TODO: check why Tagsoup removes the tags "<br/>"
     */
    @Test
    def testIsTruncated() 
    throws Exception {
        val truncator = new Truncator(Unit.character, TruncateContentHandler.NO_LIMIT, DEFAULT_CHARSET).source(HTML_DOC)
        var result = truncator.run
        assertThat(truncator.isTroncated(), equalTo(false))
        result = removeTagSoupArtifacts(result)
        assertThat(result.replaceAll("\t", ""), equalTo(unescapeHtml4(HTML_DOC).replaceAll("<br/>", "").replaceAll("\n\\s*", "")))
    }

    def private static removeTagSoupArtifacts(String o) {
        o.replaceAttributeDelimiters
            .removeShapeAttribute
            .removeEndOfLine
    }
    
    def private static replaceAttributeDelimiters(String o) {
        o.replaceAll("=\"([^\"]*)\"(\\s|>)", "='$1'$2")
    }
    
    /*
     * TagSoup adds shape attribute in a href tag
     * https://groups.google.com/forum/#!topic/tagsoup-friends/EfB6i12xBLw
     */
    def private static removeShapeAttribute(String o) {
        o.replaceAll(" shape='rect'", "")
    }
    
    def private static removeEndOfLine(String o) {
        o.replaceAll("\\n", "")
    }

    def private removeAllSpaces(String s) {
        s.replaceAll("\\s", "")
    }
    def private removeAllHtmlTags(String s) {
        s.replaceAll("</?[^>]+>", "")
    }

    def private static removeEllipsis(String s, String e) {
        s.replaceFirst("(?s)" + e +"$", "")
    }

}
