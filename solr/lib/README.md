# Querqy plugins for Solr 10

These JARs are copied into the Solr image (`/opt/querqy/lib`) and loaded via `-Dsolr.sharedLib=/opt/querqy/lib`
(see `docker-compose.yml`). Solr 10 no longer supports the `<lib/>` directive in `solrconfig.xml`.

| JAR | Source |
| --- | --- |
| `querqy-solr-5.10.solr1010.0-jar-with-dependencies.jar` | Official release for Solr 10.1, [Maven Central](https://repo1.maven.org/maven2/org/querqy/querqy-solr/5.10.solr1010.0/) (`org.querqy:querqy-solr:5.10.solr1010.0`, classifier `jar-with-dependencies`) |
| `querqy-regex-filter-1.1.0-SNAPSHOT.jar` | Local build of [renekrie/querqy-regex-filter](https://github.com/renekrie/querqy-regex-filter) @ `99c5a58` + `patches/querqy-regex-filter-solr10.patch` |
| `querqy-embeddings-rewriter-1.0.0-SNAPSHOT.jar` | Local build of [querqy/querqy-embeddings-rewriter](https://github.com/querqy/querqy-embeddings-rewriter) @ `a7ce15e` + `patches/querqy-embeddings-rewriter-solr10.patch` |

The two rewriters have no Solr 10 release, so they are built locally against Solr 10.1.0 and the querqy-solr
release above: apply the patch, then `mvn -Dmaven.test.skip=true package` in `maven:3.9.11-eclipse-temurin-21`.
Replace them with official releases once those exist.

What the patches do:

- **Both:** build against Solr 10.1.0 and querqy-solr `5.10.solr1010.0` with Java 21, and port the factory to the
  querqy-core 4 `RewriterFactory.createRewriter(SearchEngineRequestAdapter)` signature.
- **querqy-regex-filter:** ports `RegexFilterRewriter` to the current Querqy rewriter API (`QueryRewriter`
  returning `RewriterOutput`), and follows the `querqy.rewrite.commonrules` → `querqy.rewriter.commonrules`
  package move. Declares `solr-core` as `provided`, since querqy-solr does not pass it on. The tests still use the
  old API, hence `-Dmaven.test.skip=true`.
- **querqy-embeddings-rewriter:** `KnnVectorQuery` → `KnnFloatVectorQuery` (Lucene 10), removes the unused
  `Add1KnnVectorQuery`.

SHA-256:

```
82c177b7f1b8c3bcba28023a4bcf6d7d77702ba0ee5c9c9fd507609e96c2a718  querqy-solr-5.10.solr1010.0-jar-with-dependencies.jar
318e64ef7f718bf4258a5145b51065dc04fbb946e55e110803dbcceab6a32565  querqy-regex-filter-1.1.0-SNAPSHOT.jar
fbbf13b2fe7b77ce6a8ba4c38ffdcb84bd1b768fcb5c3cd21d311e9ab123c662  querqy-embeddings-rewriter-1.0.0-SNAPSHOT.jar
```
