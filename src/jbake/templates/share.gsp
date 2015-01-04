<a href="https://twitter.com/share" 
           class="twitter-share-button" 
           data-url="http://${config.site_host}/${current.uri}" 
           data-via="${config.twitter_owner}" 
           data-text="${current.title}" 
           data-lang="${config.site_locale.substring(0,2)}">Tweeter</a>
        
        <script>!function(d,s,id){
            var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';
            if(!d.getElementById(id)){
                js=d.createElement(s);
                js.id=id;js.src=p+'://platform.twitter.com/widgets.js';
                fjs.parentNode.insertBefore(js,fjs);
            }}(document, 'script', 'twitter-wjs');
        </script>
        
        <div class="g-plusone" 
            data-size="medium" 
            data-href="http://${config.site_host}/${current.uri}"></div>
                        