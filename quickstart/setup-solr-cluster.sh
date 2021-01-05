# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
RESET='\033[0m' # No Color

if ! [ -x "$(command -v zip)" ]; then
  echo 'Error: zip is not installed.' >&2
  exit 1
fi

echo -e "${MAJOR}Waiting for Solr cluster to start up and all three nodes to be online.${RESET}"
./wait-for-solr-cluster.sh # Wait for all three Solr nodes to be online

echo -e "${MAJOR}Setting up security in solr${RESET}"
echo -e "${MINOR}upload security.json to zookeeper${RESET}"
solr zk cp /quickstart/security.json zk:security.json -z zoo1:2181

echo -e "${MINOR}wait for security.json to be available to solr${RESET}"
./wait-for-zk-200.sh # Wait for all three Solr nodes to be online

echo -e "${MAJOR}Upload ecommerce configset.${RESET}"
(cd configsets/ecommerce/conf && zip -r - *) > ./configsets/ecommerce.zip
echo -e "${MINOR}post ecommerce.zip configset${RESET}"
curl  --user solr:SolrRocks -X POST --header "Content-Type:application/octet-stream" --data-binary @./configsets/ecommerce.zip "http://solr1:8983/solr/admin/configs?action=UPLOAD&name=ecommerce"

echo -e "${MAJOR}Create ecommerce collection.${RESET}"
curl --user solr:SolrRocks -X POST "http://solr1:8983/solr/admin/collections?action=CREATE&name=ecommerce&numShards=2&replicationFactor=1&collection.configName=ecommerce&waitForFinalState=true"

if [ ! -f ./icecat-products-150k-20200809.tar.gz ]; then
    echo -e "${MAJOR}Downloading the sample product data.${RESET}"
    curl --progress-bar -o icecat-products-150k-20200809.tar.gz https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
fi
echo -e "${MAJOR}Populating products, please give it a few minutes!${RESET}"
tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl 'http://solr1:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'
