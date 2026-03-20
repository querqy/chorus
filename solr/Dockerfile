FROM solr:10.0.0

#COPY --chown=solr:solr solr.xml /var/solr/data/

COPY ./lib/querqy-solr-5.6.lucene900.0-jar-with-dependencies.jar /opt/solr-10.0.0/lib
COPY ./lib/querqy-embeddings-rewriter-1.0.0-SNAPSHOT.jar /opt/solr-10.0.0/lib
COPY ./lib/querqy-regex-filter-1.1.0-SNAPSHOT.jar /opt/solr-10.0.0/lib
