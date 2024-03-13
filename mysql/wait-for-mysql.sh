DOT='\033[0;37m.\033[0m'
while [[ "$(docker inspect --format "{{json .State.Health.Status }}" mysql)" != "\"healthy\"" ]]; do printf ${DOT}; sleep 5; done
echo ""
