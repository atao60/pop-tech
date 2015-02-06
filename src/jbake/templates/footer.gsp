		</div>
		<div id="push"></div>
    </div>
    
    <div id="footer">
      <div class="container">
        <p class="text-muted credit"><% 
            out << sprintf(config.i18n_post_license,
                              """<a rel='license' href='http://creativecommons.org/licenses/by-nc-sa/4.0/'>
                <img alt='CC BY-NC-SA 4.0' style='border-width:0' 
                     src='http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png'/></a>""")
            %> <%
            out << sprintf(config.i18n_photo_credits,
                              """<a href='https://www.flickr.com/photos/chavals/'>Chaval Brasil</a>
                <a rel='license' href='http://creativecommons.org/licenses/by-nc-nd/2.0/'>
                <img alt='CC BY-NC-ND 2.0' style='border-width:0' 
                     src='http://i.creativecommons.org/l/by-nc-nd/2.0/88x31.png'/></a>""") %>
        </p>
        <p class="text-muted credit"><% 
            def validityPeriod = config.inception_year
            def currentYear = new Date().getAt(Calendar.YEAR)
            if ( currentYear > config.inception_year.toInteger() ) { 
                validityPeriod += "-${currentYear}" 
            }
            out << sprintf(config.i18n_copyright, validityPeriod,
                            "<a href='http://twitter.github.com/bootstrap/'>Bootstrap v${config.bootstrap_version}</a>",
                            "<a href='http://jbake.org'>JBake ${version}</a>") %>
        </p>
      </div>
    </div>
    
    <!-- Bootstrap core JavaScript
    ===================================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <%
        def contentRootPath = ""
        if (content.rootpath) {
            contentRootPath = content.rootpath
        }
        else if (content.type == "tag"){
            contentRootPath =  "../"
        }
    %>
    <!-- script src="/js/jquery-${config.jquery_version}${config.lib_min}.js"></script -->
    <!-- script src="/js/bootstrap${config.lib_min}.js"></script -->
    <!-- script src="${contentRootPath}js/run_prettify${config.lib_min}.js"></script -->

    <script src='${contentRootPath}js/shCore${config.lib_min}.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shAutoloader${config.lib_min}.js' type='text/javascript'></script>
    <script type='text/javascript'>
        SyntaxHighlighter.autoloader(
            ['bash','shell','${contentRootPath}js/shBrushBash${config.lib_min}.js'],
            ['java','${contentRootPath}js/shBrushJava${config.lib_min}.js'],
            ['js', 'jscript', 'javascript', '${contentRootPath}js/shBrushJScript${config.lib_min}.js'],
            ['cpp', 'c', '${contentRootPath}js/shBrushCpp${config.lib_min}.js'],
            ['css', '${contentRootPath}js/shBrushCss${config.lib_min}.js'],
            ['groovy', '${contentRootPath}js/shBrushGroovy${config.lib_min}.js'],
            ['jfx', 'javafx', '${contentRootPath}js/shBrushJavaFX${config.lib_min}.js'],
            ['php', '${contentRootPath}js/shBrushPhp${config.lib_min}.js'],
            ['plain', 'text', '${contentRootPath}js/shBrushPlain${config.lib_min}.js'],
            ['py', 'python', '${contentRootPath}js/shBrushPython${config.lib_min}.js'],
            ['ruby', 'rails', 'ror', 'rb', '${contentRootPath}js/shBrushRuby${config.lib_min}.js'],
            ['sass', 'scss', '${contentRootPath}js/shBrushSass${config.lib_min}.js'],
            ['scala', '${contentRootPath}js/shBrushScala${config.lib_min}.js'],
            ['sql', '${contentRootPath}js/shBrushSql${config.lib_min}.js'],
            ['xml', 'xhtml', 'xslt', 'html', '${contentRootPath}js/shBrushXml${config.lib_min}.js'],
            ['diff', 'patch', 'pas', '${contentRootPath}js/shBrushDiff${config.lib_min}.js'],
            ['perl', 'pl', '${contentRootPath}js/shBrushPerl${config.lib_min}.js'],
            ['erl', 'erlang', '${contentRootPath}js/shBrushErlang${config.lib_min}.js'],
            ['c# c-sharp', 'csharp', '${contentRootPath}js/shBrushCSharp${config.lib_min}.js'],
            ['applescript', '${contentRootPath}js/shBrushAppleScript${config.lib_min}.js'],
            ['vb', 'vbnet', '${contentRootPath}js/shBrushVb${config.lib_min}.js'],
            ['delphi', 'pascal', '${contentRootPath}js/shBrushDelphi${config.lib_min}.js']
        );
        SyntaxHighlighter.config.bloggerMode = ${config.sh_blogger_mode};
        SyntaxHighlighter.defaults['toolbar'] = ${config.sh_toolbar};  
        SyntaxHighlighter.all();
    </script>
    
    <!-- Asynchronous loading of Google API -->
    <!-- Placed after the last Google+ button -->
    <script type="text/javascript">
        window.___gcfg = {lang: '${config.site_locale}'};

        (function() {
            var po = document.createElement('script'); 
            po.type = 'text/javascript'; 
            po.async = true;
            po.src = 'https://apis.google.com/js/platform.js';
            var s = document.getElementsByTagName('script')[0]; 
            s.parentNode.insertBefore(po, s);
        })();
    </script>
    
    <!-- Google Analytics: change UA-XXXXX-X to be your site's ID and change domain name  -->
    <script>
        (function(i,s,o,g,r,a,m){
            i['GoogleAnalyticsObject']=r;
            i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
            a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];
            a.async=1;
            a.src=g;
            m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '${config.ga_id}', '${config.ga_site}');
        ga('send', 'pageview');

    </script>
   
  </body>
</html>
