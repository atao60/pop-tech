<%include "header.gsp"%>
	
	<%include "menu.gsp"%>
	
	<div class="page-header">
        <div class="row">
            <div class="col-xs-4 col-md-2"><img src="${content.rootpath}img/poptech.png"></div>
            <div class="col-xs-12 col-md-8"><h1>${content.title}</h1></div>
        </div>
	</div>

    <div class="row">

        <div class="col-sm-8" itemscope itemtype="http://schema.org/Blog">

        <p>
            <em>
                <time itemprop="datePublished"
                      datetime="${content.date.format("yyyy-MM-dd")}">
                    ${content.date.format("dd MMMM yyyy")}
                </time>
            </em>
        </p>

        <meta itemprop="name" content="${content.title}"/>

        <div itemprop="author" itemscope itemtype="http://schema.org/Person">
            <meta itemprop="name" content="${config.owner_name}"/>
        </div>
        <meta itemprop="inLanguage" content="${config.site_locale}"/>
        <meta itemprop="url" content="${config.site_host}/${content.uri}"/>
        <meta itemprop="discussionUrl" content="${config.site_host}/${content.uri}#disqus_thread"/>

<%if (render.tags) {%>
        <p>Tags :
        <meta itemprop="keywords" content="${content.tags.join(",")}"/>
        <%
            out << content.tags.collect { post_tag ->
                """<a href="${content.rootpath}tags/${post_tag}.html">${post_tag}</a>"""
            } .join(", ")
        %>
        </p>
<%}%>
        <%  current=content
            include "share.gsp"%>
        
        <div itemprop="blogPost">
        <p>${content.body}</p>
        </div>

        <div id="disqus_thread"></div>
        <script type="text/javascript">
            var disqus_shortname = '${config.disqus_shortname}';
            var disqus_identifier = '${content.id}';
            (function() {
                var dsq = document.createElement('script'); 
                dsq.type = 'text/javascript'; 
                dsq.async = true;
                dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
                (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
            })();
        </script>
        <noscript>Please enable Javascript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus</a></noscript>
    </div>

    <div class="col-sm-3 col-sm-offset-1 blog-sidebar">
<%include "owner.gsp"%>

<%rootpath=content.rootpath + "tags/"
  include "alltags.gsp"%>

    </div>
	
<%include "footer.gsp"%>
