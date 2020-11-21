DOT='\033[0;37m.\033[0m'
while [[ "$(curl -s 'http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS' | jq '.cluster.live_nodes | length ')" != "3" ]]; do printf ${DOT}; sleep 5; done
echo ""
