DOT='\033[0;37m.\033[0m'
while [[ "$(curl -s 'http://keycloak:9080/auth/realms/solr' | jq '.realm')" != '"solr"' ]]; do printf ${DOT}; sleep 5; done
echo ""
