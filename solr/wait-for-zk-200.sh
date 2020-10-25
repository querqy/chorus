echo "Polling for security.json existence"
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8983/solr/admin/zookeeper?path=/security.json&detail=true)" != "200" ]]; do sleep 5; done'
