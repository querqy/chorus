DOT='\033[0;37m.\033[0m'
ERROR='\033[0;31m[QUICKSTART] '
RESET='\033[0m' # No Color

while [[ "$(curl -s 'http://keycloak:9080/realms/chorus' | jq '.realm')" != '"chorus"' ]]; do printf ${DOT}; sleep 5; done
echo ""
