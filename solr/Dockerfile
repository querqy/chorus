FROM solr:10.1.0

COPY --chown=solr:solr solr.xml /var/solr/data/

# Loaded via -Dsolr.sharedLib=/opt/querqy/lib (see docker-compose.yml and lib/README.md)
COPY ./lib/querqy-solr-5.10.solr1010.0-jar-with-dependencies.jar /opt/querqy/lib/
COPY ./lib/querqy-embeddings-rewriter-1.0.0-SNAPSHOT.jar /opt/querqy/lib/
COPY ./lib/querqy-regex-filter-1.1.0-SNAPSHOT.jar /opt/querqy/lib/
