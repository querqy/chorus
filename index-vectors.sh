#!/bin/bash

DATA_DIR="solr/data"
if [ -d "$DATA_DIR" ]
then
	if [ "$(ls -A $DATA_DIR)" ]; then
	  cd $DATA_DIR
	  for f in *.json;
	    do
	      echo "Populating products from $f , please give it a few minutes!"
        curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @"$f" -H 'Content-type:application/json ';
       done;
	else
    echo "$DATA_DIR is Empty"
	fi
else
	echo "Directory $DATA_DIR not found."
fi
