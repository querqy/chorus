#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

source helpers.sh

set -e

log_awesome "Thank you for trying Chorus! Welcome!"

observability=false
shutdown=false
offline_lab=false
local_deploy=true
apple_silicon=false

KEYCLOAK_ADMIN_PASSWORD=password12345

while [ ! $# -eq 0 ]
do
	case "$1" in
		--help | -h)
      display_help_message
			exit
			;;
		--with-observability | -obs)
			observability=true
      log_major "Running Chorus with observability services enabled"
			;;
    --with-offline-lab | -lab)
			offline_lab=true
      log_major "Running Chorus with offline lab environment enabled"
			;;
    --apple-silicon | -apple)
      apple_silicon=true
      log_major "Configuring Chorus for Apple Silicon"
      ;;
    --online-deployment | -online)
			local_deploy=false
      log_major "Configuring Chorus for chorus.dev.o19s.com environment"
			;;
    --shutdown | -s)
			shutdown=true
      log_major "Shutting down Chorus"
			;;
	esac
	shift
done

# Function check_prerequisites makes sure that you have curl, jq, docker-compose, and zip installed. See helpers.sh for details.
check_prerequisites

services="blacklight solr1 solr2 solr3 keycloak smui"

if $observability; then
  services="${services} grafana solr-exporter jaeger"
fi

if $offline_lab; then
  services="${services} quepid rre"
fi

if $apple_silicon; then
  export KEYCLOAK_DOCKER_PLATFORM=linux/arm64/v8
else
  export KEYCLOAK_DOCKER_PLATFORM=linux/amd64
fi

if ! $local_deploy; then
  log_major "Updating configuration files for online deploy"
  sed -i.bu 's/localhost:3000/chorus.dev.o19s.com:3000/g'  ./keycloak/realm-config/chorus-realm.json
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./keycloak/realm-config/chorus-realm.json
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./keycloak/wait-for-keycloak.sh
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./solr/wait-for-solr-cluster.sh
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./solr/wait-for-zk-200.sh
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./solr/security.json
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./docker-compose.yml
fi

docker-compose down -v
if $shutdown; then
  exit
fi

docker-compose up -d --build ${services}

log_major "Waiting for Solr cluster to start up and all three nodes to be online."
./solr/wait-for-solr-cluster.sh # Wait for all three Solr nodes to be online

log_major "Setting up security in solr"
log_minor "copying security.json into image"
docker cp ./solr/security.json solr1:/security.json

if $local_deploy; then
  ./keycloak/check-for-host-configuration.sh
fi

log_minor "waiting for Keycloak to be available"
./keycloak/wait-for-keycloak.sh

log_minor "uploading security.json to zookeeper"
docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

log_minor "waiting for security.json to be available to all Solr nodes"
./solr/wait-for-zk-200.sh

log_major "Packaging ecommerce configset."
(cd solr/configsets/ecommerce/conf && zip -r - *) > ./solr/configsets/ecommerce.zip
log_minor "posting ecommerce.zip configset"
curl  --user solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @./solr/configsets/ecommerce.zip "http://localhost:8983/api/cluster/configs/ecommerce"
log_major "Creating ecommerce collection."
curl --user solr:SolrRocks -X POST http://localhost:8983/api/collections -H 'Content-Type: application/json' -d'
  {
    "create": {
      "name": "ecommerce",
      "config": "ecommerce",
      "numShards": 2,
      "replicationFactor": 1,
      "waitForFinalState": true
    }
  }
'

if [ ! -f ./icecat-products-150k-20200809.tar.gz ]; then
    log_major "Downloading the sample product data."
    curl --progress-bar -o icecat-products-150k-20200809.tar.gz -k https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
fi
log_major "Populating products, please give it a few minutes!"
tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'

log_major "Defining relevancy algorithems using ParamSets."
curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/config/params -H 'Content-type:application/json'  -d '{
  "set": {
    "visible_products":{
      "fq":["price:*", "-img_500x500:\"\""]
    }
  },
  "set": {
    "default_algo":{
      "defType":"edismax",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "mustmatchall_algo":{
      "deftype":"edismax",
      "mm":"100%",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "querqy_algo":{
      "defType":"querqy",
      "querqy.rewriters":"replace,common_rules,regex_screen_protectors",
      "querqy.infoLogging":"on",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "querqy_algo_prelive":{
      "defType":"querqy",
      "querqy.rewriters":"replace_prelive,common_rules_prelive,regex_screen_protectors",
      "querqy.infoLogging":"on",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
}'


log_major "Setting up SMUI"
SOLR_INDEX_ID=`curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Chorus Webshop"}' http://localhost:9000/api/v1/solr-index | jq -r .returnId`
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"brand"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field

if $offline_lab; then
  log_major "Setting up Quepid"
  ./mysql/wait-for-mysql.sh

  docker-compose run --rm quepid bin/rake db:setup
  docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password
  echo -e "${MINOR}Setting up Chorus Baseline Relevance case${RESET}"
  docker-compose run quepid thor case:create "Chorus Baseline Relevance" solr http://localhost:8983/solr/ecommerce/select JSONP "id:id, title:title, thumb:img_500x500, name, brand, product_type" "q=#\$query##&useParams=visible_products,querqy_algo" nDCG@10 admin@choruselectronics.com
  docker cp ./katas/Broad_Query_Set_rated.csv quepid:/srv/app/Broad_Query_Set_rated.csv
  docker exec quepid thor ratings:import 1 /srv/app/Broad_Query_Set_rated.csv >> /dev/null


  log_major "Setting up RRE"
  docker-compose run rre mvn rre:evaluate
  docker-compose run rre mvn rre-report:report
fi

if $observability; then
  log_major "Setting up Grafana"
  curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://localhost:9091/api/admin/users
  curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://localhost:9091/api/admin/users/2/permissions
  curl -u admin:password -S -X POST -H "Content-Type: application/json" http://localhost:9091/api/users/2/using/1
fi

log_awesome "Chorus is now running!"
