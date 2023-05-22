#!/bin/bash

DATA_DIR="./solr/data/fashion"

cd $DATA_DIR
for f in fashion-vectors*.json;
  do
    echo "Populating products from ${f}, please give it a few minutes!"
    curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @"$f" -H 'Content-type:application/json ';
    sleep 5
   done;
