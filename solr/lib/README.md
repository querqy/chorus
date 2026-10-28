# Querqy plugins for Solr 10

These JARs are copied into the Solr image (`/opt/querqy/lib`) and loaded via `-Dsolr.sharedLib=/opt/querqy/lib`
(see `docker-compose.yml`). Solr 10 no longer supports the `<lib/>` directive in `solrconfig.xml`.

**These are interim builds.** At the time of the Solr 10 upgrade there was no released querqy-solr for Solr 10
(the maintainers plan one after Solr 10.1.0, see https://github.com/querqy/querqy-solr/pull/11). Replace them
with official releases once those exist.

| JAR | Source | Built with |
| --- | --- | --- |
| `querqy-solr-5.10.lucene1021.0-SNAPSHOT-jar-with-dependencies.jar` | [querqy/querqy-solr](https://github.com/querqy/querqy-solr) branch `solr1010` @ `c076ec8` | `patches/querqy-solr-solr1010-on-10.0.0.patch`, `mvn -Dsolr.version=10.0.0 -Dquerqy-lucene.version=5.9.lucene1032.0 -DskipTests package` |
| `querqy-regex-filter-1.1.0-SNAPSHOT.jar` | [renekrie/querqy-regex-filter](https://github.com/renekrie/querqy-regex-filter) @ `99c5a58` | `patches/querqy-regex-filter-solr10.patch`, `mvn -Dmaven.test.skip=true package` |
| `querqy-embeddings-rewriter-1.0.0-SNAPSHOT.jar` | [querqy/querqy-embeddings-rewriter](https://github.com/querqy/querqy-embeddings-rewriter) @ `a7ce15e` | `patches/querqy-embeddings-rewriter-solr10.patch`, `mvn -Dmaven.test.skip=true package` |

Build the rewriters after `mvn install` of querqy-solr. All builds use `maven:3.9.11-eclipse-temurin-21`.
Despite its version string, the querqy-solr JAR is built against Solr 10.0.0 / Lucene 10.3.2.

What the patches do:

- **querqy-solr:** works around the invalid `solr-core-10.0.0.pom` (it drops all transitive dependencies, so
  they are declared as `provided`), and inlines `SolrPluginUtils.parseMinShouldMatch`, which only exists after
  Solr 10.0.0.
- **querqy-regex-filter:** ports `RegexFilterRewriter` to the current Querqy rewriter API (`QueryRewriter`
  returning `RewriterOutput`), plus the same POM workaround.
- **querqy-embeddings-rewriter:** `KnnVectorQuery` → `KnnFloatVectorQuery` (Lucene 10), removes the unused
  `Add1KnnVectorQuery`, plus the same POM workaround.
