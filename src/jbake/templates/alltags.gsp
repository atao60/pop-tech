            <div class="sidebar-module">
                <h4>Tags</h4>
                <ol class="list-unstyled" style="margin-left: 0px"><%
                        alltags.collect { tag ->
                            [
                                tag,
                                posts.findAll { post ->
                                    post.tags.contains(tag)
                                }.size()
                            ]
                        } .sort { tag ->
                            String.format("%03d%s", 1000 - tag[1], tag[0].toLowerCase())
                        } .each { tagWithCount ->%>
                        <li><a href="${rootpath}${tagWithCount[0]}.html">${tagWithCount[0]}</a> (${tagWithCount[1]})</li><%
                        }%>
                 </ol>
            </div>
            