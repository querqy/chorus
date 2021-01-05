DOT='\033[0;37m.\033[0m'
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://solr1:8983/solr/admin/zookeeper?path=/security.json&detail=true)" != "200" ]]; do printf ${DOT}; sleep 5; done
echo ""
