#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

set -e


# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
RESET='\033[0m' # No Color


if ! [ -x "$(command -v curl)" ]; then
  echo '${ERROR}Error: curl is not installed.${RESET}' >&2
  exit 1
fi
if ! [ -x "$(command -v docker-compose)" ]; then
  echo '${ERROR}Error: docker-compose is not installed.${RESET}' >&2
  exit 1
fi
if ! [ -x "$(command -v jq)" ]; then
  echo '${ERROR}Error: jq is not installed.${RESET}' >&2
  exit 1
fi
if ! [ -x "$(command -v zip)" ]; then
  echo 'Error: zip is not installed.' >&2
  exit 1
fi


observability=false

while [ ! $# -eq 0 ]
do
	case "$1" in
		--help | -h)
			echo -e "Use the option --with-observability | -o to include Grafana, Prometheus, and Solr Exporter services in Chorus."
			exit
			;;
		--with-observability | -o)
			observability=true
      echo -e "${MAJOR}Running Chorus with observability services enabled${RESET}"
			;;
	esac
	shift
done

services="blacklight solr1 solr2 solr3 smui quepid rre"
if $observability; then
  services="${services} grafana solr-exporter"
fi

docker-compose down -v
docker-compose up -d --build ${services}

echo -e "${MAJOR}Waiting for Solr Cluster to start up and all three nodes to be online.${RESET}"
./solr/wait-for-solr-cluster.sh # Wait for all three Solr nodes to be online

echo -e "${MAJOR}Setting up security in solr${RESET}"
echo -e "${MINOR}copy security.json into image${RESET}"
docker cp ./solr/security.json solr1:/security.json
echo -e "${MINOR}upload security.json to zookeeper${RESET}"
docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

echo -e "${MINOR}wait for security.json to be available to solr${RESET}"
./solr/wait-for-zk-200.sh # Wait for all three Solr nodes to be online

echo -e "${MAJOR}Upload ecommerce configset.${RESET}"
# Fix me to not be buried under solr/solr_home/.
(cd solr/solr_home/ecommerce/conf && zip -r - *) > ./solr/solr_home/ecommerce.zip
echo -e "${MINOR}post ecommerce.zip configset${RESET}"
curl  --user solr:SolrRocks -X POST --header "Content-Type:application/octet-stream" --data-binary @./solr/solr_home/ecommerce.zip "http://localhost:8983/solr/admin/configs?action=UPLOAD&name=ecommerce"

echo -e "${MAJOR}Create ecommerce collection.${RESET}"
docker exec solr1 solr create_collection -c ecommerce -n ecommerce -shards 2 -replicationFactor 1
echo -e "${MINOR}sleep 5${RESET}"
sleep 5
if [ ! -f ./icecat-products-150k-20200809.tar.gz ]; then
<<<<<<< HEAD
<<<<<<< HEAD
    echo -e "${MAJOR}Downloading the sample product data.${RESET}"
    wget https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
=======
    curl -o icecat-products-150k-20200809.tar.gz https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
>>>>>>> move from wget to curl, and then check for existance of tools
=======
  echo -e "${MAJOR}Downloading the sample product data.${RESET}"
  curl -o icecat-products-150k-20200809.tar.gz https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
>>>>>>> mergin
fi
echo -e "${MAJOR}Populating products, please give it a few minutes!${RESET}"
tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'

echo -e "${MAJOR}Setting up SMUI${RESET}"
SOLR_INDEX_ID=`curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index | jq -r .returnId`
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -S -X PUT -H "Content-Type: application/json" -d '{"name":"brand"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field

echo -e "${MAJOR}Setting up Quepid${RESET}"
docker-compose run --rm quepid bin/rake db:setup
docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password

echo -e "${MAJOR}Setting up RRE${RESET}"
docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report

if $observability; then
  echo -e "${MAJOR}Setting up Grafana${RESET}"
  curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://localhost:9091/api/admin/users
  curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://localhost:9091/api/admin/users/2/permissions
  curl -u admin:password -S -X POST -H "Content-Type: application/json" http://localhost:9091/api/users/2/using/1
fi
<<<<<<< HEAD

echo -e "${MAJOR}Welcome to Chorus!${RESET}"
=======
>>>>>>> mergin
