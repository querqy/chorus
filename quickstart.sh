#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

docker-compose down -v
docker-compose up -d --build
sleep 30 # takes a while to start everything.

docker cp ./solr/security.json solr1:/security.json
docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

# Fix me to not be buried under solr/solr_home/.
(cd solr/solr_home/ecommerce/conf && zip -r - *) > ./solr/solr_home/ecommerce.zip
curl  --user solr:SolrRocks -X POST --header "Content-Type:application/octet-stream" --data-binary @./solr/solr_home/ecommerce.zip "http://localhost:8983/solr/admin/configs?action=UPLOAD&name=ecommerce"

docker exec solr1 solr create_collection -c ecommerce -n ecommerce -shards 2 -replicationFactor 1

sleep 5
if [ ! -f ./icecat-products-150k-20200809.tar.gz ]; then
    wget https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
fi
echo "Populating products, please give it a few minutes!"
tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'

SOLR_INDEX_ID=`curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index | jq -r .returnId`
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"brand"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field


docker-compose run --rm quepid bin/rake db:setup
docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password

docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report
sleep 5
curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://localhost:3001/api/admin/users
curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://localhost:3001/api/admin/users/2/permissions
curl -u admin:password -S -X POST -H "Content-Type: application/json" http://localhost:3001/api/users/2/using/1
