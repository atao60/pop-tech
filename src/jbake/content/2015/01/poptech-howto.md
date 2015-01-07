title=Un blog dans le nuage
date=2015-01-04
type=post
tags=blog,maven,jbake,git,github,cloud9
status=draft
id=poptech-howto
~~~~~~

Le défi ici est de créer un blog en n'utilisant que des moyens disponibles dans le nuage. Sans débourser un centime.

Ce petit manuel passe en revue les principales étapes pour créer un blog avec [JBake](http://jbake.org/) et le publier grâce à [Github](https://github.com/). Le tout en utilisant [Cloud9](https://c9.io) comme EDI afin de pouvoir gérer le blog depuis n'importe quel ordinateur.

Prérequis
-----

Pour suivre ce manuel, vous aurez besoin d'un compte pour chacun des services suivants&nbsp;: 

* [Cloud9](https://c9.io),
* [Github](https://github.com/), 
* [Disqus](https://disqus.com),
* [Google Analytics](http://www.google.fr/intl/fr/analytics).

L'environnement de travail doit disposer de&nbsp;:

* [Java](http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html), 
* [Maven](http://maven.apache.org/),
* [Git](http://git-scm.com).

Le tout sous [Ubuntu](www.ubuntu.com). Et oui, c'est possible grâce à [Cloud9](https://c9.io).

Configurer un compte [Cloud9](https://c9.io)
------

Créer un compte depuis la page d'accueil.

Depuis le tableau de bord de ce compte, créer un espace de travail, par ex. ... poptech !
Conserver le type Custom. et en mode Hosted

Sélectionner le nouveau projet et ouvrir une scession&nbsp;: cliquer sur "Start Editing".

Vérifier la version de java installée&nbsp;:
<pre class="brush: shell"><code>
$ java -version
java version "1.7.0_65"
OpenJDK Runtime Environment (IcedTea 2.5.3) (7u71-2.5.3-0ubuntu0.14.04.1)
OpenJDK 64-Bit Server VM (build 24.65-b04, mixed mode)
</code></pre>

Vérifier la version de Maven installée&nbsp;:
<pre class="brush: shell">$ mvn -version
Apache Maven 2.2.1 (rdebian-14)
Java version: 1.7.0_65
Java home: /usr/lib/jvm/java-7-openjdk-amd64/jre
Default locale: en, platform encoding: UTF-8
OS name: "linux" version: "3.14.13-c9" arch: "amd64" Family: "unix"
</pre>

<pre class="brush: shell"><code>$ mvn -version
Apache Maven 2.2.1 (rdebian-14)
Java version: 1.7.0_65
Java home: /usr/lib/jvm/java-7-openjdk-amd64/jre
Default locale: en, platform encoding: UTF-8
OS name: "linux" version: "3.14.13-c9" arch: "amd64" Family: "unix"
</code></pre>

```brush: shell
$ mvn -version
Apache Maven 2.2.1 (rdebian-14)
Java version: 1.7.0_65
Java home: /usr/lib/jvm/java-7-openjdk-amd64/jre
Default locale: en, platform encoding: UTF-8
OS name: "linux" version: "3.14.13-c9" arch: "amd64" Family: "unix"
```

Configurer un dépôt [Github](https://github.com/)
-----

Créer un nouveau blog
------

Il est toujours possible de forker le présent [blog](https://github.com/atao60/pop-tech) ou celui de [Yan bonnel](http://github.com/ybonnel/blog). Ou même de partir de [jbake-sample](http://github.com/ingenieux/jbake-sample).

Pour les besoins de la démonstration, le nouveau blog sera construit à partir d'un projet Maven vide.















La suite
------
* les templates
* importation sous Eclipse
* une adresse IP propre, www.popsuite.net => un compte chez un mandataire, ici BookMyname (payant)
* un compte twitter
