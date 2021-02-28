# Watch for SOLR-14216 to be completed, and switch to /api/node/health
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' -H "Authorization: Bearer ${KEYCLOAK_TOKEN}" http://solr1:8983/solr/ecommerce/admin/ping)" != "200" ]]; do sleep 5; done'
