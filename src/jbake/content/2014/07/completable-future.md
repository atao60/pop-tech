title=Back to the (Completable)Future
date=2014-07-23
type=post
tags=java8,CompletableFuture
status=published
id=completable-future
~~~~~~

Je vais aujourd'hui vous présenter les [CompletableFuture](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html) de java 8.
 
Pour l'exemple, nous allons réaliser un petit programme Java permettant de récupérer le titre le plus long parmi les articles du blog.
Pour faire cela, nous allons récupérer la page [archive](http://www.ybonnel.fr/archive.html) du blog, pour ensuite récupérer chaque lien d'article et pour finir récupérer le titre des articles.

# Méthode naïve

Commençons par la méthode naïve sans java8 :
<script src="https://gist.github.com/ybonnel/fd339f7df77ea325a52e.js"></script>

Cette méthode a l'intérêt d'être très facilement compréhensible, par contre c'est beaucoup trop séquentiel, il faudrait pouvoir exécuter les requêtes en parallel et non de manière séquentiel.
 
# Méthode à base de Future
 
Nous allons maintenant exécuter les requêtes en parallel à l'aide d'un bon vieux ExecutorService : 
<script src="https://gist.github.com/ybonnel/58d0d23a348573ab101d.js"></script>

Cette méthode est beaucoup plus performante, mais un truc me gène :

    boolean allDone = false;
    while (!allDone) {
        allDone = true;
        for (Future<String> result : results) {
            if (!result.isDone()) {
                allDone = false;
                break;
            }
        }
        Thread.sleep(50);
    }

Avoir du code technique de ce type là en plein milieu, ça me plait pas trop.

UPDATE : Comme on me l'a fait remarquer sur twitter, il est tout a fait possible de supprimer ce bloc, l'attente étant gérée par le get.
Cependant on ne voit plus de notion de "tout les traitements terminés", ce qui dans un cas plus complexe peux être très utile.

# Méthode à base de CompletableFuture

Nous allons maintenant transformer notre code pour utiliser les CompletableFuture de java8 :
<script src="https://gist.github.com/ybonnel/a077022e9a2b504f7446.js"></script>

Personnellement je trouve ce code beaucoup plus lisible et sans (ou très peu de) code technique.

Quelques détails sur l'API :

* [CompletableFuture.supplyAsync](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#supplyAsync-java.util.function.Supplier-java.util.concurrent.Executor-) : permet d'exécuter un traitement en asynchrone, retourne le CompletableFuture correspondant.
* [CompletableFuture.allOf](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#allOf-java.util.concurrent.CompletableFuture...-) : Permet de récupérer un CompletableFuture correspondant à la fin de tous les CompletableFuture passés en paramètres.
* [CompletableFuture.thenApply](http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html#thenApply-java.util.function.Function-) : Execute un fonction une fois le CompletableFuture terminé. Cette fonction prend en paramètre l'objet du CompletableFuture est renvoie un autre type. 

# Performances

Voici les résultats des trois méthodes en terme de performances :

* Méthode naïve : 2243ms
* Méthode à base de Future : 310ms
* Méthode à base de CompletableFuture : 230ms


Pour les curieux, l'ensemble de ma classe de test se trouve [ici](https://github.com/ybonnel/simpleweb4j-blog/blob/master/src/main/java/fr/ybonnel/blog/CompletableFutureTest.java).

