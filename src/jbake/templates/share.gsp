<a href="https://twitter.com/share" 
           class="twitter-share-button" 
           data-url="${config.site_host}/${current.uri}" 
           data-via="${config.twitter_owner}" 
           data-text="${current.title}" 
           data-lang="${config.site_locale.substring(0,2)}">${config.i18n_tweet.capitalize()}</a>
        
        <div class="g-plusone" 
            data-size="medium" 
            data-href="${config.site_host}/${current.uri}"></div>
                        