#FROM openjdk:11-jre
FROM solr:8.7.0


USER root
# Best practice is slow!
RUN apt-get update && apt-get install -y \
  curl wget jq zip \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /quickstart
COPY security.json /quickstart/security.json
COPY *.sh /quickstart/
COPY configsets /quickstart/configsets

# Not having luck with this.  Getting later message that the file is gzip: stdin: not in gzip format
#ADD https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz /quickstart/icecat-products-150k-20200809.tar.gz

RUN chmod +x /quickstart/*.sh
#RUN chmod +r /quickstart/icecat-products-150k-20200809.tar.gz
RUN chown -R 8983:8983 /quickstart

USER solr

WORKDIR /quickstart
