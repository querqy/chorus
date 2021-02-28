FROM solr:8.8.1

# We need the fix in SOLR-15194 and are waiting for next Solr release.
COPY ./lib/solr-core-8.9.0-SNAPSHOT.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/solr-core-8.8.1.jar
COPY ./lib/solr-solrj-8.9.0-SNAPSHOT.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/solr-solrj-8.8.1.jar

COPY ./lib/querqy-solr-4.9.lucene810.0-jar-with-dependencies.jar /opt/querqy/lib/
#COPY ./lib/streaming-expressions-1.0.0-solr8.5.0-SNAPSHOT.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
