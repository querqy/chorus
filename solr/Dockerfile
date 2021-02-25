#FROM solr:8.8.0
# Pending SOLR-15194 being committed and released.
FROM apache/solr:9.0.0-SNAPSHOT

COPY ./security.json /opt/querqy/lib/security.json
COPY ./lib/querqy-solr-4.9.lucene810.0-jar-with-dependencies.jar /opt/querqy/lib/
COPY ./lib/streaming-expressions-1.0.0-solr8.5.0-SNAPSHOT.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
