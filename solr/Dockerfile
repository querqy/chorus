FROM solr:9.1.0

COPY --chown=solr:solr solr.xml /var/solr/data/

COPY ./lib/querqy-solr-5.4.lucene900.0-jar-with-dependencies.jar /opt/querqy/lib/
COPY ./lib/querqy-regex-filter-1.1.0-SNAPSHOT.jar /opt/querqy/lib/
