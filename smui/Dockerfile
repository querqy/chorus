FROM querqy/smui:3.14.0

COPY conf/smui2solrcloud.sh /smui/conf/smui2solrcloud.sh
COPY conf/*.py /smui/conf/
COPY conf/predefined_tags.json /smui/conf/predefined_tags.json

USER root
RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
USER smui
RUN python3 -m pip install requests
