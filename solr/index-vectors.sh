#!/bin/bash

source settings.sh # settings.sh is located in the chorus root directory, and since this script is called from there, no "../" prefix here is necessary 
source helpers.sh # helpers.sh, ditto

DATA_DIR="./solr/data"
S3_PRODUCT_VECTORS_LOCATION="https://o19s-public-datasets.s3.amazonaws.com/chorus/product-vectors-2023-02-08"

for i in {1..4}
do
	if [ ! -f $DATA_DIR/products-vectors-$i.json ]; then
		log_major "Downloading the products-vectors-${i}.json."
		retry_until_command_success_and_responseHeader_status_is_zero "curl --progress-bar -o ${DATA_DIR}/products-vectors-${i}.json -k ${S3_PRODUCT_VECTORS_LOCATION}/products-vectors-${i}.json"
	fi
done

cd $DATA_DIR
for f in products-vectors*.json;
do
  log_minor "Populating products from ${f}, please give it a few minutes!"
  retry_until_command_success_and_responseHeader_status_is_zero "curl -X POST --user ${SOLR_USER}:${SOLR_PASS} 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @${f} -H 'Content-type:application/json'"
done;
