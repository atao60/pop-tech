title=Pourquoi ce blog&nbsp;?
date=2014-12-24
type=post
tags=blog,maven,jbake,github,eclipse
status=published
id=this-blog
~~~~~~

Faire un blog sur mes pérégrinations informatiques me trottait dans la tête depuis un certain temps. Histoire d'en conserver une trace. Et si en plus cela pouvait servir à d'autres...

Après avoir installé un [site javadoc](http://atao60.github.io/maven-site-demo/) de démonstration sur [Github](https://github.com/) à l'aide de [Maven](http://maven.apache.org/), la possibilité de créer un blog sur le même principe est devenue incontournable. Le temps de faire le lien avec [Jekyll](http://jekyllrb.com/) puis [JBake](http://jbake.org/)&nbsp;!

Le choix de [JBake](http://jbake.org/) permet de rester dans un cadre 100% JVM.

Trois articles ont fourni les bases&nbsp;:

* [Authoring your blog on GitHub with JBake and Gradle](http://melix.github.io/blog/2014/02/hosting-jbake-github.html)  
    Cédric Champeau, 3/2/14

* [Migration de blogger à jbake](http://www.ybonnel.fr/tags/jbake.html)  
    Yan Bonnel, 2/7/14
    
* [JBake Maven Plugin Walkthough](http://docs.ingenieux.com.br/project/jbake/walkthrough.html)    

N'ayant jamais utilisé [Gradle](https://www.gradle.org/), j'ai opté pour [Maven](http://maven.apache.org/) avec l'extension [jbake-maven-plugin](https://github.com/ingenieux/jbake-maven-plugin). Yan Bonnel fournit dans son billet toutes les informations pour se lancer. D'autant qu'il met aussi à disposition le [code](http://github.com/ybonnel/blog) de son propre blog [JustAnOtherDevBlog](http://www.ybonnel.fr/). Et pour rendre à César... Cédric Champeau fait [de même](https://github.com/melix/blog) pour son [Blog](http://melix.github.io/blog/) .

Ne reste plus qu'à tester&nbsp;:

* la répercussion en temps réel des modifications sur l'affichage du blog grâce à [livereload](http://livereload.com/) qui est intégrée à [jbake-maven-plugin](https://github.com/ingenieux/jbake-maven-plugin),
* le transfert du blog vers [Github](https://github.com/) à l'aide de [Github site plugin](https://github.com/github/maven-plugins). 

Ce qui aurait dû rester une promenade de santé s'est avéré un parcours du combattant. 

Commençons avec [livereload](http://livereload.com/)&nbsp;: dès qu'une modification est enregistrée, [livereload s'arrête](https://github.com/ingenieux/jbake-maven-plugin/issues/6). Pour le moment, il faut travailler avec un [fork](https://github.com/atao60/jbake-maven-plugin) de la version 0.0.9-SNAPSHOT.

Et les déboires continuent avec [Github site plugin](https://github.com/github/maven-plugins)&nbsp;:

* la version 0.9 bloque avec des messages abscons, cf.&nbsp;[Error creating commit: Invalid request #69](https://github.com/github/maven-plugins/issues/69),

* le passage à la version 0.10 requiert une bibliothèque qui n'est pas disponible sur Maven Central, cf.&nbsp;[artifact egit.github.core 3.1.0.201310021548-r not available on maven central #74](https://github.com/github/maven-plugins/issues/74),

* et reste au final que l'API de [Github site plugin](https://github.com/github/maven-plugins) a changé&nbsp;: elle requiert maintenant que le nom et l'email du compte [Github](https://github.com/) soient renseignés, cf.&nbsp;[Error deploying when email address not public #77](https://github.com/github/maven-plugins/issues/77).
 
Pourquoi pas de fournir un nom, mais aucune envie d'une adresse email qui soit rendue publique.

Ne reste donc qu'à remplacer [Github site plugin](https://github.com/github/maven-plugins) par [maven-scm-publish-plugin](http://maven.apache.org/plugins/maven-scm-publish-plugin/).

Ah, quel plaisir d'avoir enfin son petit blog perso. Et cerise sur le gâteau&nbsp;: [Github](https://github.com/) permet de publier un tel site avec son propre nom de domaine.

Le dépôt Github du blog est disponible [ici](https://github.com/atao60/pop-tech).

Dans une série de billets à venir, je donnerai plus de détail pour arriver à ce résultat. À bientôt.

