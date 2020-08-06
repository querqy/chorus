#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

docker-compose down -v
docker-compose up -d
sleep 30 # takes a while to start everything.

docker cp ./solr/security.json solr1:/security.json
#docker run --rm -v "$PWD/solr:/target" solr:8.5.2 solr zk cp target/security.json zk:security.json -z zoo1:2181

docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

# Fix me to not be buried under solr/solr_home/.
(cd solr/solr_home/ecommerce/conf && zip -r - *) > ./solr/solr_home/ecommerce.zip
curl  --user solr:SolrRocks -X POST --header "Content-Type:application/octet-stream" --data-binary @./solr/solr_home/ecommerce.zip "http://localhost:8983/solr/admin/configs?action=UPLOAD&name=ecommerce"

docker exec solr1 solr create_collection -c ecommerce -n ecommerce -shards 2 -replicationFactor 1
# make sure we can parse properly a string into a proper date.
curl http://localhost:8983/solr/ecommerce/config -H 'Content-type:application/json' -d '
{
  "add-updateprocessor" :
  {
    "name" : "formatDateUpdateProcessor",
    "class": "solr.ParseDateFieldUpdateProcessorFactory",
    "format":["yyyy-MM-dd"]
  }
}'
sleep 5
if [ ! -f ./icecat-products-150k-20200607.tar.gz ]; then
    wget https://querqy.org/datasets/icecat/icecat-products-150k-20200607.tar.gz
fi
tar xzf icecat-products-150k-20200607.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @- -H 'Content-type:application/json'

SOLR_INDEX_ID=`curl -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index | jq .returnId`
curl -X PUT -H "Content-Type: application/json" -d '{"name":"attr_t_product_type"}' http://localhost:9000/api/v1/{$SOLR_INDEX_ID}/suggested-solr-field
curl -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/{$SOLR_INDEX_ID}/suggested-solr-field

docker-compose run --rm quepid bin/rake db:setup
docker-compose run quepid thor user:create -a demo@example.com "Demo User" password

docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report
