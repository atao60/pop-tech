<%if (config.render_tags != 'false') {%>
        <p>${config.i18n_tags.capitalize()}${config.i18n_colon}
        <meta itemprop="keywords" content="${current.tags.join(",")}"/>
        <%
            out << current.tags.collect { post_tag ->
                """<a href="${rootpath}${post_tag}.html">${post_tag}</a>"""
            } .join(", ")
        %>
        </p>
<%}%>
