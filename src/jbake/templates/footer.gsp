		</div>
		<div id="push"></div>
    </div>
    
    <div id="footer">
      <div class="container">
        <p class="text-muted credit">
            L'ensemble des posts de ce blog sont publiés sous licence 
            <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
                <img alt="CC BY-NC-SA 4.0" style="border-width:0" 
                     src="http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png"/></a>.
            Crédit photo : <a href="https://www.flickr.com/photos/chavals/">Chaval Brasil</a>
                <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/2.0/">
                <img alt="CC BY-NC-ND 2.0" style="border-width:0" 
                     src="http://i.creativecommons.org/l/by-nc-nd/2.0/88x31.png"/></a>.
        </p>
        <p class="text-muted credit">&copy; ${config.inception_year}<%
        
            def currentYear = new Date().getAt(Calendar.YEAR)
            if ( currentYear > config.inception_year.toInteger() ) { out << "-${currentYear}" }
        %> | Mixed with <a href="http://twitter.github.com/bootstrap/">Bootstrap v${config.bootstrap_version}</a> | Baked with <a href="http://jbake.org">JBake ${version}</a></p>
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
    <!-- script src="/js/jquery-${config.jquery_version}.min.js"></script -->
    <!-- script src="/js/bootstrap.min.js"></script -->
    <script src="${contentRootPath}js/run_prettify.js"></script>

    <script src='${contentRootPath}js/shCore.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushCss.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushJava.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushJScript.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushSql.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushVb.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushXml.js' type='text/javascript'></script>
    <script src='${contentRootPath}js/shBrushBash.js' type='text/javascript'></script>


    <script type="text/javascript">
        SyntaxHighlighter.config.bloggerMode = true;
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
