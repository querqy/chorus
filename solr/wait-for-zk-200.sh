DOT='\033[0;37m.\033[0m'
while [[ "$(curl -s --user solr:SolrRocks -o /dev/null -w ''%{http_code}'' "http://localhost:8983/solr/admin/zookeeper?path=/security.json&detail=true")" != "200" ]]; do printf ${DOT}; sleep 5; done
echo ""
