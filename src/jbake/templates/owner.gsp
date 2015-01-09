        <div class="sidebar-module sidebar-module-inset">
            <h4>${config.owner_name}</h4>
            <p>${config.owner_presentation}</p>
            
            <ul><%
            if (config.twitter_owner) { %>
                <li><a href="https://twitter.com/${config.twitter_owner}">@${config.twitter_owner}</a></li><%
            } 
            if (config.googlep_id) { %>
                <li><a href="https://plus.google.com/${config.googlep_id}?rel=author">+${config.googlep_owner}</a></li><%
            } %>
            </ul>
            
        </div>

     