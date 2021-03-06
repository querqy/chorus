FROM querqy/smui:3.12.1

COPY conf/smui2solrcloud.sh /smui/conf/smui2solrcloud.sh
COPY conf/*.py /smui/conf/

USER root
RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
USER smui
RUN python3 -m pip install requests
