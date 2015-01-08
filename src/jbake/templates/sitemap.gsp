<?xml version="1.0" encoding="${config.site_encoding.toUpperCase()}"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
    <url>
        <loc>${config.site_host}/index.html</loc>
        <lastmod>${published_date.format("yyyy-MM-dd")}</lastmod>
    </url>
    <url>
        <loc>${config.site_host}/archive.html</loc>
        <lastmod>${published_date.format("yyyy-MM-dd")}</lastmod>
    </url><%
    alltags.each { tag -> 
            def lastMod = posts.findAll { post ->
                post.tags.contains(tag)
            } .collect { post ->
                post.date
            } .max(); %>
    <url>
        <loc>${config.site_host}/tags/${tag}.html</loc>
        <lastmod>${lastMod.format("yyyy-MM-dd")}</lastmod>
    </url><%
  }
   published_content.each { content -> %>
    <url>
        <loc>${config.site_host}/${content.uri}</loc>
        <lastmod>${content.date.format("yyyy-MM-dd")}</lastmod>
    </url><%
}
%>
</urlset>
