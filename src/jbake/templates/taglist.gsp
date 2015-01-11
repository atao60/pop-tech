<%if (config.render_tags != 'false') {
    label = (current.tags.size() > 1) ? config.i18n_tags : config.i18n_tag
    tagList = " -"
    if ( current.tags.size() > 0 ) {
        tagList = current.tags.collect { post_tag ->
                "<a href='${rootpath}${post_tag}.html'>${post_tag}</a>"
            } .join(", ")
    }
}%>
        <p>${label.capitalize()}${config.i18n_colon}
            <meta itemprop="keywords" content="${current.tags.join(",")}"/>
            ${tagList}</p>

