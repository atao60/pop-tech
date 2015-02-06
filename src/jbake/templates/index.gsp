<%
import popsuite.blog.util.Truncator
rootpath="tags/"%><%include "header.gsp"%>

	<%include "menu.gsp"%>

	<div class="page-header">
        <div class="row">
            <div class="col-xs-4 col-md-2"><img src="img/${config.site_logo}"></div>
            <div class="col-xs-12 col-md-8"><h1>${config.site_name}</h1></div>
        </div>
	</div>

    <div class="row">

        <div class="col-sm-8">

            <% posts.take(5).each { post -> %>
                <%if (post.status == "published") {%>
                    <div  itemscope itemtype="http://schema.org/Blog">
                        <div itemprop="author" itemscope itemtype="http://schema.org/Person">
                            <meta itemprop="name" content="${config.owner_name}"/>
                        </div>
                        <meta itemprop="inLanguage" content="${config.site_locale}"/>
                        <a itemprop="url" href="${post.uri}">
                            <h1 itemprop="name">${post.title}</h1>
                        </a>
                        <p>
                            <time itemprop="datePublished"
                                  datetime="${post.date.format("yyyy-MM-dd")}">
                                ${post.date.format("dd MMMM yyyy")}
                            </time>
                        </p>

                        <%current=post
                          include 'taglist.gsp'
                          include "share.gsp"%>

                        <div itemprop="blogPost">
                            <% def summary_length = config.summary_length.toInteger()
                               if (post.summaryLength != null && !post.summaryLength.isEmpty()) {
                                  summary_length = post.summaryLength.toInteger()
                               }
                               def ellipsis = config.summary_ellipsis
                               def readmore = String.format("${config.summary_readmore}", post.uri)
                               def truncator = new Truncator(summary_length).readmore(readmore).ellipsis(ellipsis).source(post.body)
                               out << truncator.run()%>
                         </div><!-- end of blogPost -->
                        <p><a itemprop="discussionUrl" href="${post.uri}#disqus_thread">${config.i18n_comments.capitalize()}</a></p>

                    </div>
                <%}%>

            <%}%>

            <hr />

            <p><%out << sprintf(config.i18n_olderposts,config.archive_file)%></p>

        </div>

        <div class="col-sm-3 col-sm-offset-1 blog-sidebar">
        
<%include "owner.gsp"%>

            <div class="sidebar-module">
                <a class="twitter-timeline"  
                   href="https://twitter.com/${config.twitter_owner}"  
                   data-widget-id="${config.twitter_id}"><%out << sprintf(config.i18n_tweetsfrom,config.twitter_owner)%></a>
                <script>!function(d,s,id){
                    var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';
                    if (!d.getElementById(id)) {
                        js=d.createElement(s);
                        js.id=id;
                        js.src=p+"://platform.twitter.com/widgets.js";
                        fjs.parentNode.insertBefore(js,fjs);
                    }}(document,"script","twitter-wjs");
                </script>
            </div>

<%include "alltags.gsp"%>

        </div>

    </div>

<%include "sharescripts.gsp"%>
<%include "footer.gsp"%>
