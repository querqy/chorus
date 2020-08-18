FROM querqy/smui:3.6.1

COPY conf/smui2solrcloud.sh /smui/conf/smui2solrcloud.sh
COPY conf/jackhanna-0.0.4-SNAPSHOT.jar /smui/conf/jackhanna-0.0.4-SNAPSHOT.jar

# This is a temporary shim to allow us to write to /usr/bin/solr/preliveCore/conf
# since the user running SMUI is smui.
USER root
RUN chmod -R 0777 /usr
