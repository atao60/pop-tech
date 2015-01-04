      <!-- Fixed navbar -->
      <div class="navbar navbar-default navbar-fixed-top" role="navigation">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-menu">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="<%
                    if (content.rootpath) {
                        %>${content.rootpath}<%
                    } else if (content.type == "tag"){
                        %>../<%
                    }
                %>index.html">${config.site_name}</a>
          </div>
          <div class="collapse navbar-collapse" id="navbar-menu">
            <ul class="nav navbar-nav">
              <li><a href="https://github.com/${config.github_owner}" target="github:${config.github_owner}">Github</a></li>
              <li><a href="<%
                    if (content.rootpath) {
                        %>${content.rootpath}<%
                    } else if (content.type == "tag"){
                        %>../<%
                    }
                    %>archive.html">${config.i18n_archives.capitalize()}</a></li>
              <li><a href="<%
                    if (content.rootpath) {
                        %>${content.rootpath}<%
                    } else if (content.type == "tag") {
                        %>../<%
                    }
                    %>${config.feed_file}">${config.i18n_feed.capitalize()}</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
      <div class="container">
