<%rootpath=""%>
<%include "header.gsp"%>
	
	<%include "menu.gsp"%>

	<div class="page-header">
            <div class="row">
                <div class="col-xs-4 col-md-2"><img src="../img/poptech.png"></div>
                <div class="col-xs-12 col-md-8"><h1>${config.i18n_tag.capitalize()}${config.i18n_colon} ${tag}</h1></div>
            </div>
	</div>

    <div class="row">

        <div class="col-sm-8">
        <% tag_posts.each { post -> %>
            <%if (post.status == "published") {%>
                <a href="../${post.uri}"><h1>${post.title}</h1></a>
                <p>${post.date.format("dd MMMM yyyy")}</p>

                <%current=post
                  include 'taglist.gsp'
                  include "share.gsp"%>
        
                <p>${post.body}</p>
                <p><a href="${post.uri}#disqus_thread">${config.i18n_comments.capitalize()}</a></p>
            <%}%>

        <%}%>

        </div>

        <div class="col-sm-3 col-sm-offset-1 blog-sidebar">

<%include "owner.gsp"%>

<%include "alltags.gsp" %>

        </div>

    </div>

<%include "sharescripts.gsp"%>
<%include "footer.gsp"%>
