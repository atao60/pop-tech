title=Migration de blogger à jbake
date=2014-07-02
type=post
tags=blogger,jbake,github
status=published
id=migrate-blogger-to-jbake
~~~~~~
Je vous en ai parlé la semaine dernière dans cet [article](http://www.ybonnel.fr/2014/06/nouveau-blog.html), je suis passé de blogger à jbake.

Le but de l'article d'aujourd'hui sera de de donner un certain nombre d'astuces autour de cette migration, plus quelques astuces sur jbake.

# Mise en place de Jbake

Quand j'ai commencé, je me suis basé sur le post de [Cédric](http://melix.github.io/blog/2014/02/hosting-jbake-github.html), mais j'ai finalement décidé d'abandonner gradle pour passer à mon vieil ami Maven.

La raison de ce changement est assez simple, je connais bien maven :)

J'utilise le plugin [jbake-maven-plugin](https://github.com/jbake-org/jbake-maven-plugin) sur lequel j'ai fait deux [pull request](https://github.com/jbake-org/jbake-maven-plugin/pulls).
La première pull request est pour qu'il supporte jbake 2.3.0, la deuxième est pour qu'il démarre un serveur livrereload sur le goal inline.

Si ces pull request sont mergées, ou si vous utilisez mon [fork](https://github.com/ybonnel/jbake-maven-plugin), les tests sont plutôt simples, il suffit de lancer :
```
mvn jbake:inline
```
Ouvrez ensuite http://localhost:8080, si vous activez livereload, dès que vous faites une modification, un refresh est déclenché, plutôt cool, non?

Concernant la publication sur github, j'utilise le plugin de github : [github-site-plugin](http://github.github.com/maven-plugins/site-plugin/).

Si vous voulez voir les détails, vous pouvez regarder mon [pom.xml](https://github.com/ybonnel/blog/blob/master/pom.xml).

# Migration des articles

Je ne voulais pas réécrire les anciens articles à la main, il a donc fallu que je trouve une procédure automatisée.

Je suis parti du flux rss de blogger, et pour chaque article je crée un fichier html dans mes sources jbake.
Ma classe permettant celà est disponible [ici](https://github.com/ybonnel/blog/blob/master/src/main/java/BloggerToJbake.java).

# Migration des commentaires

Pour la migration des commentaires, j'ai été surpris, ça marche tout seul avec [disqus](https://help.disqus.com/customer/portal/articles/1218656-importing-comments-from-blogger-to-disqus).

# Quelques astuces sur les templates

## Tags

J'avais commencé avec des templates freemarker, mais j'ai pas réussi à faire ce que je voulais avec.
Je voulais afficher la liste des tags avec entre parenthèses le nombre d'articles possédant ce tag, le tout ordonné par nombre d'articles décroissant.
Je n'ai trouvé aucune solution (sans code java) pour faire ça avec freemarker, alors qu'en groovy c'est relativement simple :
<script src="https://gist.github.com/ybonnel/4ec6f22377331d8a47e8.js"></script>

## Sitemap des tags

Voici le petit bout de code qui me permet de positionner la date de mise à jour des pages de type tag (correspondant au dernier article sur ce tag) :
<script src="https://gist.github.com/ybonnel/deec4ef0f1dcc0d07b68.js"></script>

# Open-source

Pour finir, si vous voyez un truc qui pourrait être amélioré sur le blog, il est maintenent [open-source](https://github.com/ybonnel/blog/).
