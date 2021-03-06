<%
import popsuite.blog.util.Truncator
import org.apache.commons.lang3.StringEscapeUtils
def encoding = config.site_encoding.toUpperCase()
def language = config.site_locale  // this page is always generated with the site locale.
%><?xml version="1.0" encoding="${encoding}"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>${config.site_name}</title>
    <link>${config.site_host}</link>
    <atom:link href="${config.site_host}/${config.feed_file}" rel="self" type="application/rss+xml" />
    <description>${config.site_description}</description>
    <language>${language}</language>
      <pubDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(published_date)}</pubDate>
      <lastBuildDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(published_date)}</lastBuildDate>

      <%published_posts.each {post -> %>
      <item>
          <title>${StringEscapeUtils.unescapeHtml4(post.title)}</title>
          <link>${config.site_host}/${post.uri}</link>
          <pubDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(post.date)}</pubDate>
          <guid isPermaLink="false">${config.site_host}/${post.uri}</guid>
          <description>
              <% 
                 def ellipsis = config.summary_ellipsis
                 def readmore = ""
                 def summary = ""
                 if (post.summary != null && !post.summary.trim().isEmpty()) {
                    summary = post.summary
                 } else {
                    def summary_length = config.summary_length.toInteger()
                    if (post.summaryLength != null && !post.summaryLength.isEmpty()) {
                       summary_length = post.summaryLength.toInteger()
                    } 
                    def truncator = new Truncator(summary_length).readmore(readmore).ellipsis(ellipsis).source(post.body)
                    summary = truncator.run()
                 } 
                 
                 out << StringEscapeUtils.escapeXml(summary)
              %>  
          </description>
      </item>
      <%}%>

  </channel> 
</rss>
