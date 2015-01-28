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

    <script src='${contentRootPath}js/shCore.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shAutoloader.js' type='text/javascript'></script>
    <script type='text/javascript'>
        SyntaxHighlighter.autoloader(
            ['bash','shell','${contentRootPath}js/shBrushBash.js'],
            ['java','${contentRootPath}js/shBrushJava.js'],
            ['js', 'jscript', 'javascript', '${contentRootPath}js/shBrushJScript.js'],
            ['cpp', 'c', '${contentRootPath}js/shBrushCpp.js'],
            ['css', '${contentRootPath}js/shBrushCss.js'],
            ['groovy', '${contentRootPath}js/shBrushGroovy.js'],
            ['jfx', 'javafx', '${contentRootPath}js/shBrushJavaFX.js'],
            ['php', '${contentRootPath}js/shBrushPhp.js'],
            ['plain', 'text', '${contentRootPath}js/shBrushPlain.js'],
            ['py', 'python', '${contentRootPath}js/shBrushPython.js'],
            ['ruby', 'rails', 'ror', 'rb', '${contentRootPath}js/shBrushRuby.js'],
            ['sass', 'scss', '${contentRootPath}js/shBrushSass.js'],
            ['scala', '${contentRootPath}js/shBrushScala.js'],
            ['sql', '${contentRootPath}js/shBrushSql.js'],
            ['xml', 'xhtml', 'xslt', 'html', '${contentRootPath}js/shBrushXml.js'],
            ['diff', 'patch', 'pas', '${contentRootPath}js/shBrushDiff.js'],
            ['perl', 'pl', '${contentRootPath}js/shBrushPerl.js'],
            ['erl', 'erlang', '${contentRootPath}js/shBrushErlang.js'],
            ['c# c-sharp', 'csharp', '${contentRootPath}js/shBrushCSharp.js'],
            ['applescript', '${contentRootPath}js/shBrushAppleScript.js'],
            ['vb', 'vbnet', '${contentRootPath}js/shBrushVb.js'],
            ['delphi', 'pascal', '${contentRootPath}js/shBrushDelphi.js']
        );
        SyntaxHighlighter.config.bloggerMode = ${config.sh_blogger_mode};
<% /*        SyntaxHighlighter.defaults['toolbar'] = false;  */ %>
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
