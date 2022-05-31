FROM solr:9.0.0

# This is required by Solr 9, but not in Solr 8!
RUN mkdir /var/solr/data


COPY ./lib/querqy-solr-5.4.lucene900.0-jar-with-dependencies.jar /opt/querqy/lib/
COPY ./lib/querqy-regex-filter-1.1.0-SNAPSHOT.jar /opt/querqy/lib/
