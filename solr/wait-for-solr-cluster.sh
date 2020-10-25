echo "Waiting for Solr cluster to be ready"
while [[ "$(curl -s 'http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS' | jq '.cluster.live_nodes | length ')" != "3" ]]; do sleep 5; done
