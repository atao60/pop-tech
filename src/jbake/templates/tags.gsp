<%include "header.gsp"%>
	
	<%include "menu.gsp"%>

	<div class="page-header">
            <div class="row">
                <div class="col-xs-4 col-md-2"><img src="../img/poptech.png"></div>
                <div class="col-xs-12 col-md-8"><h1>Tag: ${tag}</h1></div>
            </div>
	</div>

    <div class="row">

        <div class="col-sm-8">
        <% tag_posts.each { post -> %>
            <%if (post.status == "published") {%>
                <a href="../${post.uri}"><h1>${post.title}</h1></a>
                <p>${post.date.format("dd MMMM yyyy")}</p>

                <p>Tags :
                <%
                        out << post.tags.collect { post_tag ->
                            """<a href="${post_tag}.html">${post_tag}</a>"""
                        } .join(", ")
                %>
                </p>

                <%  current=post
                    include "share.gsp"%>
        
                <p>${post.body}</p>
                <p><a href="${post.uri}#disqus_thread">Commentaires</a></p>
            <%}%>

        <%}%>

        </div>

        <div class="col-sm-3 col-sm-offset-1 blog-sidebar">

<%include "owner.gsp"%>

<%rootpath=""
  include "alltags.gsp" %>

        </div>

    </div>

<%include "footer.gsp"%>
