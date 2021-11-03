# Official Release
#FROM solr:8.10.0

# produced by building locally your Solr
#FROM apache/solr:9.0.0-SNAPSHOT

# produced by Apache Solr project
FROM apache/solr-nightly:9.0.0-SNAPSHOT

# This is required by Solr 9, but not in Solr 8!
RUN mkdir /var/solr/data

COPY ./lib/querqy-solr-5.1.lucene810.0-jar-with-dependencies.jar /opt/querqy/lib/
COPY ./lib/querqy-regex-filter-1.1.0-SNAPSHOT.jar /opt/querqy/lib/
COPY ./lib/streaming-expressions-1.0.0-solr8.5.0-SNAPSHOT.jar /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
