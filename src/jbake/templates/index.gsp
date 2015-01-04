<%include "header.gsp"%>
	
	<%include "menu.gsp"%>

	<div class="page-header">
        <div class="row">
            <div class="col-xs-4 col-md-2"><img src="img/poptech.png"></div>
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
                        <meta itemprop="inLanguage" content="fr-FR"/>
                        <a itemprop="url" href="${post.uri}">
                            <h1 itemprop="name">${post.title}</h1>
                        </a>
                        <p>
                            <time itemprop="datePublished"
                                  datetime="${post.date.format("yyyy-MM-dd")}">
                                ${post.date.format("dd MMMM yyyy")}
                            </time>
                        </p>

                        <p>Tags :
                            <meta itemprop="keywords" content="${post.tags.join(",")}"/>
                            <%
                                out << post.tags.collect { post_tag ->
                                    """<a href="tags/${post_tag}.html">${post_tag}</a>"""
                                } .join(", ")
                            %>
                        </p>

                        <%current=post
                          include "share.gsp"%>

                        <div itemprop="blogPost">
                            <p>${post.body}</p>
                        </div>
                        <p><a itemprop="discussionUrl" href="${post.uri}#disqus_thread">Commentaires</a></p>

                    </div>
                <%}%>

            <%}%>

            <hr />

            <p>Billets plus anciens disponibles sur la page <a href="${config.archive_file}">archive</a>.</p>

        </div>

        <div class="col-sm-3 col-sm-offset-1 blog-sidebar">
        
<%include "owner.gsp"%>

            <div class="sidebar-module">
                <a class="twitter-timeline"  
                   href="https://twitter.com/${config.twitter_owner}"  
                   data-widget-id="${config.twitter_id}">Tweets de @${config.twitter_owner}</a>
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

<%rootpath="tags/"
  include "alltags.gsp"%>

        </div>

    </div>

<%include "footer.gsp"%>
