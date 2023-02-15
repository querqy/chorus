#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

source settings.sh
source helpers.sh

set -e

log_reset
log_awesome "Thank you for trying Chorus!"
log_reset

if ! [ -x "$(command -v curl)" ]; then
  log_error "curl is not installed."
  exit 1
fi
if ! [ -x "$(command -v docker-compose)" ]; then
  log_error "docker-compose is not installed."
  exit 1
fi
if ! [ -x "$(command -v jq)" ]; then
  log_error "jq is not installed."
  exit 1
fi
if ! [ -x "$(command -v zip)" ]; then
  log_error "zip is not installed."
  exit 1
fi

while [ ! $# -eq 0 ]
do
	case "$1" in
		--help | -h)
      echo -e "Use the option --with-offline-lab | -lab to include Quepid and RRE services in Chorus."
			echo -e "Use the option --with-observability | -obs to include Grafana, Prometheus, and Solr Exporter services in Chorus."
      echo -e "Use the option --with-vector-search | -vector to include Vector Search services in Chorus."
      echo -e "Use the option --with-active-search-management | -active to include Active Search Management in Chorus."
      echo -e "Use the option --shutdown | -s to shutdown and remove the Docker containers and data."
      echo -e "Use the option --online-deployment | -online to update configuration to run on chorus.dev.o19s.com environment."
			exit
			;;
		--with-observability | -obs)
			observability=true
      log_major "Configuring Chorus with observability services enabled"
			;;
    --with-offline-lab | -lab)
			offline_lab=true
      log_major "Configuring Chorus with offline lab environment enabled"
			;;
    --online-deployment | -online)
			local_deploy=false
      log_major "Configuring Chorus for chorus.dev.o19s.com environment"
			;;
	  --with-vector-search | -vector)
  		vector_search=true
      log_major "Configuring Chorus with vector search services enabled"
  		;;
    --with-active-search-management | -active)
  		active_search_management=true
      log_major "Configuring Chorus with active search management enabled"
  		;;
    --with-apple-silicon | -apple)
      export DOCKER_DEFAULT_PLATFORM=linux/arm64
      export DOCKER_DEFAULT_PLATFORM2=linux/arm64/v8
      log_major "Configuring Chorus for Apple silicon"
      ;;
    --shutdown | -s)
			shutdown=true
      log_major "Shutting down Chorus"
			;;
	esac
	shift
done

## Download models (clip and minilm) before starting embeddings service
# THIS IS NOW DONE IN embeddings DOCKERFILE
#if [ $vector_search ]; then
#  MODEL_DIR_1="./embeddings/app/clip-ViT-L-14.model"
#  MODEL_DIR_2="./embeddings/app/all-MiniLM-L12-v2.model"
#  if [ ! -d "$MODEL_DIR_1" ]; then
#      python embeddings/app/clip/loadModel.py
#  fi
#  if [ ! -d "$MODEL_DIR_2" ]; then
#      python embeddings/app/minilm/loadModel.py
#  fi
#fi

services="blacklight solr1 solr2 solr3 keycloak"
if $observability; then
  services="${services} grafana solr-exporter jaeger"
fi

if $offline_lab; then
  services="${services} quepid rre"
fi

if $vector_search; then
  services="${services} embeddings"
fi

if $active_search_management; then
  services="${services} smui"
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

log_minor "Copying security.json into image"
docker cp ./solr/security.json solr1:/security.json

if $local_deploy; then
  ./keycloak/check-for-host-configuration.sh
fi

log_minor "Waiting for Keycloak to be available"
./keycloak/wait-for-keycloak.sh

log_minor "Uploading security.json to zookeeper"
docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

log_minor "Waiting for security.json to be available to all Solr nodes"
./solr/wait-for-zk-200.sh

log_major "Packaging ecommerce configset."
(cd solr/configsets/ecommerce/conf && zip -r - *) > ./solr/configsets/ecommerce.zip

log_minor "Posting ecommerce.zip configset"
retry_until_command_success_and_responseHeader_status_is_zero "curl -s --user ${SOLR_USER}:${SOLR_PASS} -X PUT -H \"Content-Type:application/octet-stream\" --data-binary @./solr/configsets/ecommerce.zip http://localhost:8983/api/cluster/configs/ecommerce"

log_major "Creating ecommerce collection."
retry_until_command_success_and_responseHeader_status_is_zero "curl -s --user ${SOLR_USER}:${SOLR_PASS} http://localhost:8983/api/collections -H \"Content-Type:application/json\" -d '{\"create\":{\"name\":\"ecommerce\",\"config\":\"ecommerce\",\"numShards\":2,\"replicationFactor\":1,\"waitForFinalState\":true}}'"

if $vector_search; then
  # Populating product data for vector search
  log_major "Populating products for vector search, please give it a few minutes!"
  ./solr/index-vectors.sh
else
  # Populating product data for non-vector search
  if [ ! -f ./solr/data/icecat-products-150k-20200809.tar.gz ]; then
    log_major "Downloading the sample product data."
    retry_until_command_success_and_responseHeader_status_is_zero "curl --progress-bar -o ./solr/data/icecat-products-150k-20200809.tar.gz -k https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz"
  fi
  log_major "Populating products, please give it a few minutes!"
  tar xzf ./solr/data/icecat-products-150k-20200809.tar.gz --to-stdout | curl --user $SOLR_USER:$SOLR_PASS 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'
fi

# Embedding service for vector search
log_major "Preparing embeddings rewriter."

curl --user $SOLR_USER:$SOLR_PASS -X POST http://localhost:8983/solr/ecommerce/querqy/rewriter/embtxt?action=save -H 'Content-type:application/json' -d '{
  "class": "querqy.solr.embeddings.SolrEmbeddingsRewriterFactory",
         "config": {
             "model" : {
               "class": "querqy.embeddings.ChorusEmbeddingModel",
               "url": "http://embeddings:8000/minilm/text/",
               "normalize": false

             }
         }
}'

curl --user $SOLR_USER:$SOLR_PASS -X POST http://localhost:8983/solr/ecommerce/querqy/rewriter/embimg?action=save -H 'Content-type:application/json' -d '{
  "class": "querqy.solr.embeddings.SolrEmbeddingsRewriterFactory",
         "config": {
             "model" : {
               "class": "querqy.embeddings.ChorusEmbeddingModel",
               "url": "http://embeddings:8000/clip/text/",
               "normalize": false

             }
         }
}'

log_major "Defining relevancy algorithms using ParamSets."
curl --user $SOLR_USER:$SOLR_PASS -X POST http://localhost:8983/solr/ecommerce/config/params -H 'Content-type:application/json' -d '{
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
  "set": {
    "querqy_boost_by_img_emb":{
      "defType":"querqy",
      "querqy.rewriters":"embimg",
      "querqy.embimg.topK": 100,
      "querqy.embimg.mode": "BOOST",
      "querqy.embimg.boost": 10000,
      "querqy.embimg.f": "product_image_vector",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"
    }
  },
  "set": {
    "querqy_match_by_img_emb":{
      "defType":"querqy",
      "querqy.rewriters":"embimg",
      "querqy.embimg.topK":100,
      "querqy.embimg.mode": "MAIN_QUERY",
      "querqy.embimg.f": "product_image_vector",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"

    },
    "querqy_boost_by_txt_emb":{
      "defType":"querqy",
      "querqy.rewriters":"embtxt",
      "querqy.embtxt.topK": 100,
      "querqy.embtxt.mode": "BOOST",
      "querqy.embtxt.boost": 10000,
      "querqy.embtxt.f": "product_vector",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"
    },
    "querqy_match_by_txt_emb":{
      "defType":"querqy",
      "querqy.rewriters":"embtxt",
      "querqy.embtxt.topK":100,
      "querqy.embtxt.mode": "MAIN_QUERY",
      "querqy.embtxt.f": "product_vector",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"
    }
  },
}'


if $active_search_management; then
  log_major "Setting up SMUI"
  SOLR_INDEX_ID=`curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Chorus Webshop"}' http://localhost:9000/api/v1/solr-index | jq -r .returnId`
  curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
  curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
  curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"brand"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
fi

if $offline_lab; then
  log_reset
  log_major "Setting up Quepid"
  ./mysql/wait-for-mysql.sh

  docker-compose run --rm quepid bin/rake db:setup
  docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password
  log_minor "Setting up Chorus Baseline Relevance case"
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

log_reset
log_awesome "Welcome to Chorus!"
log_reset