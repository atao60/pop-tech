Pop Tech
========

A blog with static pages generated by [jbake](http://jbake.org) and hosted by [Github](https://github.com/).

The howto is inspired by the blog of [Y. Bonnel blog](http://www.ybonnel.fr/), hosted [here](https://github.com/ybonnel/blog).

Changes
----

* Doesn't use [Github Site Plugin](http://github.com/github/maven-plugins) but [maven-scm-publish-plugin](http://maven.apache.org/plugins/maven-scm-publish-plugin/).
* Generate excerpts for the index and feed pages. 
* Share parameters between maven and jbake-maven-plugin.
* Libraries for css and js can be upgraded with maven.
* Misc. (i18n, tag counters, escaped rss titles, ...)

Display
----

To see the blog, go on [Github](http://atao60.github.io/pop-tech) or on [popsuite](http://www.popsuite.net).

Edit
-----

The posts can be written with any of these formats: Markdown, AsciiDoc and HTML.

Run
------

* To update the frameworks (bootstrap, prettify, ...):

>      mvn clean initialize -Dsetup-assets   
      
* To install the Java classes in the local m2 repository (see roadmap below):

>      mvn install        

* To preview the changes:

>      mvn clean initialize jbake:inline

>    and go to [http://localhost:8083](http://localhost:8083)  
    (the port is defined by "jbake.port" in the pom file).
      
* Before publishing, save the changes on Github.   

* To publish the changes:
	  
>      mvn clean jbake:generate scm-publish:publish-scm
	  
Roadmap
------

* Add license files

* Apache Tika 1.7
	  
References
------	  

* [Authoring your blog on GitHub with JBake and Gradle](http://melix.github.io/blog/2014/02/hosting-jbake-github.html), Cédric Champeau, 03/02/2014 
  
* [Migration de blogger à jbake](http://www.ybonnel.fr/2014/07/migrate-blogger-to-jbake.html), Yan Bonnel, 02/07/2014

* [JBake Maven Plugin Walkthrough](http://docs.ingenieux.com.br/project/jbake/walkthrough.html)	  
	  
Credits, licenses, copyright
------

* Pop Tech posts are published under [Creative Commons by-nc-sa 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/).

* Groovy templates and Java classes are under [Apache 2 license](http://www.apache.org/licenses/LICENSE-2.0).

* Photos : [Chaval Brasil](https://www.flickr.com/photos/chavals/) ([CC BY-NC-ND 2.0](https://creativecommons.org/licenses/by-nc-nd/2.0/))