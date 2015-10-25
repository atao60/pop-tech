title=Embarquement immédiat et sans souci pour JavaEE 7 
date=2015-10-20
type=post
tags=javaee7, wildfly-swarm, payara-micro, capsule
status=published
id=javaee7-runnable-fatjar
summary=Un tchat embarqué avec soit <span style="font-style: italic;">Wildfly</span> soit <span style="font-style: italic;">Glassfish</span> grâce à <a href='http://wildfly.org/swarm/'>Wildfly Swarm</a>, <a href='http://www.payara.co.uk/introducing_payara_micro'>Payara-Micro</a> et <a href='http://www.capsule.io/'>Capsule</a>. <span style="font-weight: bold;">English version available.</span>
~~~~~~

> <span style="font-weight: bolder;">For English-speaking reader: you can get the pith and substance of this post <a href="https://github.com/atao60/javaee7-websocket-chat">here</a>.</span>

Vous venez juste de récupérer un programme de démonstration. Vite, vous voulez vérifier qu'il fonctionne. Avant même de vous plonger dans ses arcades. Et là, quelle frustration : après un coup de make, maven ou Dieu sait quoi, la démonstration plante.

Quelle que soit la raison de votre intérêt pour cette démonstration, justifiera-t-elle de consacrer du temps à trouver l'origine du problème ? Et cela va-t-il prendre une minute ? Une heure ? Une journée ?

Angoisse de l'incertitude...

Et la reconnaissance infinie à tout créateur d'un programme qui a pris le temps de fournir une démonstration auto-exécutable !

Dans l'univers Java, lancer une application à partir d'une archive jar n'est pas une idée neuve. Il suffit de créer une **fatjar** qui embarque une classe avec une méthode `main` et de générer un manifest en conséquence. 

### YAPUKA ! 

Alors pourquoi si peu de démonstrations se donnent la peine d'être ainsi disponibles ? Peut-être pour deux raisons toutes << bêtes >> :

* le manque d'outils pour générer simplement et automatiquement de telles archives ;
* la difficulté à embarquer un serveur WEB ou un serveur d'application.

Or aujourd'hui la majorité des applications sont conçues pour tourner sur un serveur.

Les serveurs WEB tels que [Jetty](http://www.eclipse.org/jetty/) fournissent déjà depuis un certain temps des versions embarquables. Mais les serveurs d'application pour JavaEE brillaient par leur absence sur le sujet. 

Portées par l'intérêt récent pour le nuage et les micro-services, ont émergé depuis peu des réponses à cette situation avec:

* une série d'outils gérant tous les aspects fastidieux de la création de fatjars auto-exécutables ;
* des versions embarquables pour les serveurs d'application open source les plus connus, soit [TomEE](http://tomee.apache.org/), [Glassfish](https://glassfish.java.net/) et [Wildfly](http://wildfly.org/).

Nombre de ces réponses sont open source et s'appellent [Spring-Boot](http://projects.spring.io/spring-boot/), [Backset](https://github.com/chkal/backset), [Wildfly Swarm](http://wildfly.org/swarm/), [Payara-Micro](http://www.payara.co.uk/introducing_payara_micro), [Capsule](http://www.capsule.io/), ...

### YAPUKA (bis) ...

Tout cela est encore bien neuf, et quelque peu mal dégrossi : versions alpha, manque de documentation, ... Les trucs habituels.

Et puis comme l'indique le titre du présent billet, ici seules des solutions JavaEE 7 ont droit de cité. Exit *TomEE*, du moins en attendant la [version 7.0](https://twitter.com/struberg/status/608179461058625536).

Restent *Glassfish* avec *Payara-Micro* et *Wildfly* avec *Wildfly Swarm*.

### Un chat de derrière les fagots

Ah, le petit frisson avant de se jeter à l'eau. Même si les exemples restent rares sur le WEB, ils existent. Prenons par exemple [Creating a Chat Application using Java EE 7, Websockets and GlassFish 4](http://www.hascode.com/2013/08/creating-a-chat-application-using-java-ee-7-websockets-and-glassfish-4/) dont le code est disponible sur [Bitbucket](https://bitbucket.org/hascode/javaee7-websocket-chat/). Ma reconnaissance éternelle à [Micha Kops](http://www.micha-kops.com/).

Comme le titre du billet en question l'indique, cet exemple crée une application de tchat en utilisant des websockets, le tout avec *Glassfish*. Il s'agit maintenant d'obtenir une distribution sous forme d'une archive fatjar, tant pour *Glassfish* que pour *Wildfly*.

Après le rituel usuel, soit :

- cloner le projet sous *Eclipse*, 
- le déclarer comme projet *Maven* (être à la page, d'accord, mais il y a des limites : [Gradle](http://gradle.org/) se sera pour plus tard),
- configurer les extensions *Maven* (OK, là c'est déjà moins "habituel" mais je ne peux résister ; par ailleurs le projet est ainsi prêt pour passer à *Maven Polyglot*),
- mettre à niveaux les versions des extensions *Maven* et des bibliothèques côté serveur (ajout du profil `enforce`), mais laisser en l'état les ressources côté client (ici [Bootstrap](http://getbootstrap.com/)),
- faire plaisir à M2Eclipse pour qu'il se tienne tranquille (profil `only-under-eclipse`), 
- gérer le port depuis le pom (mais pourquoi tous les exemples codent en dur le 8080 alors que si un port a d'être déjà pris ce sera lui !),

passons aux choses sérieuses.  

> Note. Le code finalisé est disponible depuis ce [dépôt Github](https://github.com/atao60/javaee7-websocket-chat). Le fichier README.md donne les instructions pour chaque scénario présenté ci-après.


### Ne jouons pas sur les mots

Un clarification de vocabulaire s'impose ici :

|français|anglais|commentaire
|---|---|---|
|archive jar << lourde >> | *fatjar* | Une archive jar qui intègre toutes les dépendances requises. Elle peut ou non être auto-exécutable ( *runnable* ).|
|serveur embarqué | *embedded server* | Un serveur qui sera installé et démarré à la demande, par ex. pour la durée d'un test ou avec un fatjar auto-exécutable.|
|serveur autonome | *standalone server* | Un serveur embarqué avec ou sans une application pré-installée, sous la forme d'un fatjar auto-exécutable. Aucun serveur n'a besoin d'être disponible par ailleurs. Seule une JVM est requise.|


La définition ci-dessus de `standalone` diffère de celle souvent utilisée pour désigner un serveur qui fonctionne à demeure et est donc disponible pour déployer à tout moment une archive war.

### Le cas *Glassfish*

*Oracle* ne fournit pour *Glassfish* aucune facilité pour créer une archive fatjar auto-exécutable. En particulier *maven-embedded-glassfish-plugin* ne le permet pas : son seul objet est de lancer une instance du serveur pendant une construction de projet afin de procéder par ex. à des tests d'intégration.

[Payara](http://www.payara.co.uk/home) prend le relais en fournissant *Payara Micro*. Ce dernier permet de déployer à la volée une archive war avec un serveur *Glassfish*. Il n'assure pas l'intégration du tout dans une archive fatjar.

C'est *Capsule* qui prend le relais final : il suffit de lui fournir une simple classe de bootstrapping pour *Payara*, et le tour est joué. L'archive fatjar auto-exécutable est disponible.

À noter que pour le moment, l'intégration de tout cela fait appel à *maven-assembly-plugin*. Or cette extension *Mavin*, à partir de sa version 2.6, refuse de finir le build avec *Capsule* : en rester à la version 2.5.5. Voir [capsule and maven-assembly-plugin 4.5+ #93](https://github.com/puniverse/capsule/issues/93).

### Chacun chez soi

Petit souci : impossible de garder tout ce beau monde dans un unique projet *Maven*. Le fautif en est ... la classe de bootstrapping pour *Payara* dont il est question ci-dessus. *Payara Micro* marche sur les plates bandes de Wildfly.

*Payara* met à disposition 3 bibliothèques : `payara-embedded-all`, `payara-embedded-web` et `payara-micro`. Seule cette dernière fournit les classes de bootstrapping requises. Mais aussi tout un paquet de bibliothèques.

L'utilisation de profils *Maven* ne suffit pas pour séparer tout ce petit monde. Il faut créer un module spécifique pour la classe de bootstrapping ! 

Et histoire que chacun ait son chez soi, pour chaque serveur, un profil distinct gère chaque mode, embarqué ou autonome.

### *Wildfly* << embarqué >>

Dans le profil `wildfly-embedded`, *wildfly-swarm-plugin* s'occupe de tout, soit :

* créer une archive war standard et une archive fatjar auto-exécutable ;
* lancer l'archive fatjar : l'archive war embarquée est automatiquement exécutée.

À noter que ce profil ne peut pas être utilisé sous *M2Eclipse*. Avec l'extension *wildfly-swarm-plugin*, *M2Eclipse* ne sait pas arrêter le serveur : il faut alors le faire en ligne de commande depuis une console. 

### *Wildfly* << autonome >>

Dans le profil `wildfly-standalone`, là aussi *wildfly-swarm-plugin* crée l'archive fatjar auto-exécutable. Mais c'est *maven-antrun-plugin* qui la lance.

À noter que *maven-antrun-plugin* a été utilisée et non *exec-maven-plugin*, afin de permettre à *M2Eclipse* de démarrer mais aussi d'arrêter le serveur.

### *Glassfish* << embarqué >>

C'est la cas traité par l'exemple d'origine. Il est repris dans le profil `glassfish-embedded`. L'extension *maven-embedded-glassfish-plugin* s'occupe de tout, soit :

* créer une archive war standard ;
* lancer une instance du serveur et y déployer l'archive war précédante.

Aucune archive fatjar n'est créée.

À noter que *maven-embedded-glassfish-plugin* en ligne de commande doit être lancée depuis le module contenant le source des classes. 

### *Glassfish* << autonome >>

Avec le profil `glassfish-standalone` :

* une archive war standard est créée : il faut explicitement en exclure tout ce qui concerne le bootstrapping de l'application, soit *Payara Micro*, *Capsule* et la classe de bootstrapping créée pour la circonstance ;
* *maven-assembly-plugin* crée une archive fatjar qui embarque :
    + le manifest,
    + l'archive war précédante,
    + les dépendances,
    + l'archive jar de *Payara Micro*,
    + les classes de bootstrapping de *Payara Micro* et *Capsule*.
    
Il faut donc fournir à *maven-assembly-plugin* un fichier d'assemblage adéquate.

### Une première conclusion

À ce jour *Wildfly* gagne haut la main vis-à-vis :

* de la simplicité d'utilisation,
* de la taille de l'archive fatjar générée,
* du temps de lancement.

Sur le 2<sup>e</sup> point : pour une simple application avec websockets, un serveur tel que *Undertow* suffit. Cela permet de réduire de moitié la taille de l'archive fatjar ! Pour une application requérant un serveur *Glassfish* proprement dit, cet avantage devrait se réduire notablement, mais rester significatif. Et cela tant que *Payara* ne proposera pas des configurations plus modulaires.

Pour ce qui est de la simplicité, il existe une extension *Maven* qui permet de créer directement un fatjar auto-exécutable avec *Capsule* : [capsule-maven-plugin](https://github.com/chrischristo/capsule-maven-plugin). Pour le moment j'ai conservé *maven-assembly-plugin* qui permet les adaptations requises pour *Payara Micro*. Il s'agirait donc de vérifier si cette extension permet de prendre en compte ces adaptations.
   
### Pour aller plus loin

* [Migrating a JSF Application from Spring to Java EE 7/CDI](https://blogs.oracle.com/theaquarium/entry/migrating_a_jsf_application_from) 
Reza Rahman on Mar 16, 2015  

* [The Ghosts of Java EE 7 in Production: Past, Present and Future](https://blogs.oracle.com/reza/entry/the_ghosts_of_java_ee)  
Reza Rahman on Jun 08, 2015  

* [Happy second birthday, Java EE 7! How is it going in production?](http://spring.io/blog/2015/06/04/happy-second-birthday-java-ee-7-how-is-it-going-in-production)  
Juergen Hoeller, June 04, 2015   

