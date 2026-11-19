#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

source helpers.sh

set -e

log_awesome "Thank you for trying Chorus! Welcome!"


offline_lab=false
observability=false
local_deploy=true
vector_search=false
active_search_management=false
shutdown=false

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
    --shutdown | -s)
      shutdown=true
      log_major "Shutting down Chorus"
      ;;
  esac
  shift
done

# Function check_prerequisites makes sure that you have curl, jq, docker, and zip installed. See helpers.sh for details.
check_prerequisites

services="blacklight solr1 solr2 solr3 keycloak"

if $observability; then
  export OTEL_TRACES_SAMPLER="parentbased_always_on"
  services="${services} grafana jaeger"
else
  # Prevents OpenTelemetry in Solr from attempting to send traces.
  export OTEL_TRACES_SAMPLER="always_off"
fi

if $offline_lab; then
  services="${services} quepid"
fi

if $vector_search; then
  docker_memory_allocated=`docker info --format '{{json .MemTotal}}'`
  echo "Memory total is ${docker_memory_allocated}"

  if (( $docker_memory_allocated < 10737418240 )); then
    docker_memory_allocated_in_gb=$((docker_memory_allocated/1024/1024/1024))
    log_red "You have only ${docker_memory_allocated_in_gb} GB memory allocated to Docker, and you need at least 10GB for vectors demo."
  fi
fi



if ! $local_deploy; then
  echo -e "${MAJOR}Updating configuration files for online deploy${RESET}"
  sed -i.bu 's/localhost:3000/chorus.dev.o19s.com:3000/g'  ./keycloak/realm-config/chorus-realm.json
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./keycloak/realm-config/chorus-realm.json
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./keycloak/wait-for-keycloak.sh
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./solr/wait-for-solr-cluster.sh
  sed -i.bu 's/localhost:8983/chorus.dev.o19s.com:8983/g'  ./solr/wait-for-zk-200.sh
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./solr/security.json
  sed -i.bu 's/keycloak:9080/chorus.dev.o19s.com:9080/g'  ./docker-compose.yml
fi

docker compose down -t 30 -v
if $shutdown; then
  exit
fi

if $active_search_management; then  
  # need to start MySQL and verify it is up and running before starting SMUI.
  #log_major "Starting MySQL first to ensure fully available prior to starting SMUI."
  docker compose up -d mysql  
  ./mysql/wait-for-mysql.sh
  services="${services} smui"
  
fi

docker compose up -d --build ${services}

echo -e "${MAJOR}Waiting for Solr cluster to start up and all three nodes to be online.${RESET}"
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
curl  --user solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @./solr/configsets/ecommerce.zip "http://localhost:8983/api/configsets/ecommerce"
log_major "Creating ecommerce collection."
curl --user solr:SolrRocks -X POST http://localhost:8983/api/collections -H 'Content-Type: application/json' -d'
  {
    "name": "ecommerce",
    "config": "ecommerce",
    "numShards": 2,
    "replicationFactor": 1,
    "waitForFinalState": true
  }
'

if $vector_search; then
  # Populating product data for vector search
  log_major "Populating products for vector search, please give it a few minutes!"
  ./solr/index-vectors.sh
else
  # Populating product data for non-vector search
  if [ ! -f ./solr/data/icecat-products-150k-20200809.tar.gz ]; then
    log_major "Downloading the sample product data."
    curl --progress-bar -o ./solr/data/icecat-products-150k-20200809.tar.gz -k https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
  fi
  log_major "Populating products, please give it a few minutes!"
  tar xzf ./solr/data/icecat-products-150k-20200809.tar.gz --to-stdout | curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'
fi

if $vector_search; then
  # Models that Solr's language-models module uses to vectorise queries, served by the embeddings service
  log_major "Uploading the text to vector models."
  curl --user solr:SolrRocks -X PUT http://localhost:8983/solr/ecommerce/schema/text-to-vector-model-store -H 'Content-type:application/json' --data-binary @./solr/text-to-vector-models.json
  # The other replicas only read the model store when they are (re)loaded
  curl --user solr:SolrRocks -X POST http://localhost:8983/api/collections/ecommerce/reload -H 'Content-Type: application/json' -d '{}'
fi


log_major "Defining relevancy algorithms using ParamSets."
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
  "set": {
    "querqy_boost_by_img_emb":{
      "defType":"querqy",
      "bq": "{!func}product(10,query($emb_q))",
      "emb_q": "{!knn_text_to_vector model=clip f=product_image_vector topK=100 v=$q}",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"
    },
    "querqy_match_by_img_emb":{
      "defType": "lucene",
      "emb_model": "clip",
      "emb_f": "product_image_vector",
      "emb_topK": 100
    },
    "querqy_boost_by_txt_emb":{
      "defType":"querqy",
      "bq": "{!func}product(3,query($emb_q))",
      "emb_q": "{!knn_text_to_vector model=minilm f=product_vector topK=100 v=$q}",
      "qf": "id name title product_type short_description ean search_attributes",
      "querqy.infoLogging":"on",
      "mm" : "100%"
    },
    "querqy_match_by_txt_emb":{
      "defType": "lucene",
      "emb_model": "minilm",
      "emb_f": "product_vector",
      "emb_topK": 100
    },
    "querqy_match_by_ft_txt_emb":{
      "defType": "lucene",
      "emb_model": "ftbert",
      "emb_f": "finetuned_product_vector",
      "emb_topK": 100
    },
    "querqy_match_by_ft_img_emb":{
      "defType": "lucene",
      "emb_model": "ftclip",
      "emb_f": "finetuned_product_image_vector",
      "emb_topK": 100
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
  log_major "Setting up Quepid"
  ./mysql/wait-for-mysql.sh

  docker compose run --rm quepid bundle exec bin/rake db:setup
  docker compose run quepid bundle exec thor user:create -a admin@choruselectronics.com "Chorus Admin" password
  log_minor "Setting up Chorus Baseline Relevance case"
  if $local_deploy; then
    solr_collection_url=http://localhost:8983/solr/ecommerce/select
  else
    solr_collection_url=http://chorus.dev.o19s.com:8983/solr/ecommerce/select
  fi
  docker compose run quepid bundle exec thor case:create "Chorus Baseline Relevance" solr ${solr_collection_url} JSONP "id:id, title:title, thumb:img_500x500, name, brand, product_type" "q=#\$query##&useParams=visible_products,querqy_algo" nDCG@10 admin@choruselectronics.com

  docker cp ./katas/Broad_Query_Set_rated.csv quepid:/rails/Broad_Query_Set_rated.csv

  sleep 5
  docker compose start quepid
  
  docker exec quepid bundle exec thor ratings:import 1 /rails/Broad_Query_Set_rated.csv #>> /dev/null


fi

if $observability; then
  log_major "Setting up Grafana"
  curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://localhost:9091/api/admin/users
  curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://localhost:9091/api/admin/users/2/permissions
  curl -u admin:password -S -X POST -H "Content-Type: application/json" http://localhost:9091/api/users/2/using/1
fi

if $vector_search; then
  log_major "Setting up Embeddings service"
  docker compose up -d --build embeddings
  ./embeddings/wait-for-api.sh
fi

log_awesome "Chorus is now running!"
