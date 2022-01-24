bash -c 'while [[ "$(curl -s --user solr:SolrRocks -o /dev/null -w ''%{http_code}'' http://solr:8983/solr/ecommerce/admin/ping)" != "200" ]]; do sleep 5; done'
