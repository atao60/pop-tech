<%
import org.apache.commons.lang3.StringEscapeUtils
%><?xml version="1.0" encoding="${config.site_encoding.toUpperCase()}"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>${config.site_name}</title>
    <link>${config.site_host}</link>
    <atom:link href="${config.site_host}/${config.feed_file}" rel="self" type="application/rss+xml" />
    <description>${config.site_description}</description>
    <language>${config.site_locale}</language>
      <pubDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(published_date)}</pubDate>
      <lastBuildDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(published_date)}</lastBuildDate>

      <%published_posts.each {post -> %>
      <item>
          <title>${StringEscapeUtils.unescapeHtml4(post.title)}</title>
          <link>${config.site_host}/${post.uri}</link>
          <pubDate>${new java.text.SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(post.date)}</pubDate>
          <guid isPermaLink="false">${config.site_host}/${post.uri}</guid>
          <description>
              ${StringEscapeUtils.escapeXml(post.body)}  
          </description>
      </item>
      <%}%>

  </channel> 
</rss>
