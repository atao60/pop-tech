title=Pourquoi ce blog ?
date=2014-12-24
type=post
tags=blog,maven,jbake,github,eclipse
status=draft
id=this-blog
~~~~~~

L'idée de faire un blog sur mes pérégrinations informatiques me trottait dans la tête depuis un certain temps. Histoire d'en conserver une trace. Et si en plus cela pouvait servir à d'autres...  

Après avoir inqtallé un [site javadoc](http://atao60.github.io/maven-site-demo/) de démonstration sur [Github](https://github.com/) à l'aide de [Maven](http://maven.apache.org/), la possibilité de créer un blog sur le même principe est devenue incontournable. Le temps de faire le lien avec [Jekyll](http://jekyllrb.com/) puis [JBake](http://jbake.org/) !

Le choix de [JBake](http://jbake.org/) permet de rester dans une démarche 100% JVM.

Deux articles fournissent les bases techniques :

* [Authoring your blog on GitHub with JBake and Gradle](http://melix.github.io/blog/2014/02/hosting-jbake-github.html)  
    Cédric Champeau, 3/2/14

* [Migration de blogger à jbake](http://www.ybonnel.fr/tags/jbake.html)  
    Yan Bonnel, 2/7/14

N'ayant jamais utilisé [Gradle](https://www.gradle.org/), j'ai opté pour [Maven](http://maven.apache.org/). Yan Bonnel fournit dans son billet toutes les informations nécessaires. D'autant qu'il met aussi à disposition le code de son propre blog [JustAnOtherDevBlog](http://www.ybonnel.fr/).

Sauf qu'il utilise [Github site plugin](https://github.com/github/maven-plugins). Ce qui aurait dû rester simple s'est avéré un parcours du combatant :

* la version 0.9 bloque avec des messages abscons, cf. [Error creating commit: Invalid request #69](https://github.com/github/maven-plugins/issues/69),

* le passage à la version 0.10 requiert une bibliothèque qui n'est pas disponible sur Maven Central, cf. [artifact egit.github.core 3.1.0.201310021548-r not available on maven central #74](https://github.com/github/maven-plugins/issues/74),

* et reste au final que l'API de [Github site plugin](https://github.com/github/maven-plugins) a changé : elle requiert maintenant que le nom et l'email du compte [Github](https://github.com/) soient renseignés, cf.<nbsp/>[Error deploying when email address not public #77](https://github.com/github/maven-plugins/issues/77).
 
Pourquoi pas fournir un nom, mais aucune envie de fournir une adresse email qui soit rendue publique.

Ne reste donc qu'à remplacer [Github site plugin](https://github.com/github/maven-plugins) par une solution basée sur l'extension [maven-scm-publish-plugin](http://maven.apache.org/plugins/maven-scm-publish-plugin/).

Avec la serise sur le gâteau : [Github](https://github.com/) permet de publier un tel site avec son propre nom de domaine.

Dans une série de billets à venir, je donnerai le détail pour arriver à ce résultat. À bientôt.

