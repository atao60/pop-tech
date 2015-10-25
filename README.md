Pop Tech
========

A blog with static pages generated by [jbake](http://jbake.org) and hosted on [Github](https://github.com/atao60/pop-tech).

The howto is inspired by the blog of [Y. Bonnel blog](http://www.ybonnel.fr/), hosted [here](https://github.com/ybonnel/blog).

Changes
----

* Use [maven-scm-publish-plugin](http://maven.apache.org/plugins/maven-scm-publish-plugin/) in place of [Github Site Plugin](http://github.com/github/maven-plugins).
* Generate excerpts for the index and feed pages. 
* Share parameters between maven and jbake-maven-plugin.
* Use [webjars](http://www.webjars.org/) for client assets.
* Misc. (i18n, tag counters, escaped rss titles, ...)

Display
----

To see the blog, go on [Github](http://atao60.github.io/pop-tech) or on [popsuite](http://www.popsuite.net).

Edit
-----

The posts are stored under <code>src/jbake/content</code>.

They can be written with any of these formats: Markdown, AsciiDoc and HTML.

The *jbake* documentation is available [here](http://jbake.org/docs/). 

Run
------

* To update the frameworks (bootstrap, SyntaxHighlighter, ...):  
          `mvn clean process-resources -Dwebjars`  
&nbsp;            
With *M2Eclipse*, see launcher `pop-tech_setup_webjars`.          
      
* *popsuite-blog:pop-tech* itself must have been installed in the local m2 repository, otherwise:  
          `mvn clean install`        
&nbsp;            
With *M2Eclipse*, see launcher `pop-tech_clean_install`.          

* To preview the changes:  
        `mvn clean process-resources jbake:inline`  
and go to [http://localhost:8083](http://localhost:8083).  
&nbsp;            
With *M2Eclipse*, see launcher `pop-tech_clean_generate_inline`.  
The port is defined by "jbake.port" in the pom file.
      
* Before publishing, save the changes on Github.   

* To publish the changes:  
        `mvn clean jbake:generate scm-publish:publish-scm`
&nbsp;            
With *M2Eclipse*, see launcher `pop-tech_clean_generate_publish`.
	  
References
------	  

* [Authoring your blog on GitHub with JBake and Gradle](http://melix.github.io/blog/2014/02/hosting-jbake-github.html), Cédric Champeau, 03/02/2014 
  
* [Migration de blogger à jbake](http://www.ybonnel.fr/2014/07/migrate-blogger-to-jbake.html), Yan Bonnel, 02/07/2014

* [JBake Maven Plugin Walkthrough](http://docs.ingenieux.com.br/project/jbake/walkthrough.html)	 

* [Extract Webjars static resources with Gradle for jBake (or anything really...)](http://aruizca.com/extract-webjars-static-resources-with-gradle/), Angel Ruiz, 31/08/2015
	  
Credits, licenses, copyright
------

* Pop Tech posts are published under [Creative Commons by-nc-sa 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/).

* Groovy templates and Java classes are under [Apache 2 license](http://www.apache.org/licenses/LICENSE-2.0).

* Photos : [Chaval Brasil](https://www.flickr.com/photos/chavals/) ([CC BY-NC-ND 2.0](https://creativecommons.org/licenses/by-nc-nd/2.0/))