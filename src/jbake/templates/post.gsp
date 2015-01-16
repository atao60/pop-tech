<%rootpath=content.rootpath + "tags/"
%><%include "header.gsp"%>
	
	<%include "menu.gsp"%>
	
	<div class="page-header">
        <div class="row">
            <div class="col-xs-4 col-md-2"><img src="${content.rootpath}img/${config.site_logo}"></div>
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

        <%current=content
          include 'taglist.gsp'
          include "share.gsp"%>
        
        <div itemprop="blogPost">
        ${content.body}
        </div><!-- end of blogPost -->

        <div id="disqus_thread"></div>
        <script type="text/javascript">
            var disqus_shortname = '${config.disqus_shortname}';
            var disqus_identifier = '${content.id}';
            var disqus_config = function(){this.language="${config.site_locale.substring(0,2).toLowerCase()}"};
            (function() {
                var dsq = document.createElement('script'); 
                dsq.type = 'text/javascript'; 
                dsq.async = true;
                dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
                (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
            })();
        </script>
    </div>

    <div class="col-sm-3 col-sm-offset-1 blog-sidebar">
<%include "owner.gsp"%>

<%include "alltags.gsp"%>

    </div>
	
<%include "sharescripts.gsp"%>
<%include "footer.gsp"%>
