#!/bin/bash

DATA_DIR="./solr/data"
if [ ! -f ./solr/data/finetuned-products-vectors-1.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-1.json.${RESET}"
  curl --progress-bar -o ./solr/data/finetuned-products-vectors-1.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-finetuned-vectors-2023-06/finetuned-products-vectors-1.json
fi
if [ ! -f ./solr/data/finetuned-products-vectors-2.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-2.json.${RESET}"
  curl --progress-bar -o ./solr/data/finetuned-products-vectors-2.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-finetuned-vectors-2023-06/finetuned-products-vectors-2.json
fi
if [ ! -f ./solr/data/finetuned-products-vectors-3.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-3.json.${RESET}"
  curl --progress-bar -o ./solr/data/finetuned-products-vectors-3.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-finetuned-vectors-2023-06/finetuned-products-vectors-3.json
fi
if [ ! -f ./solr/data/finetuned-products-vectors-4.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-4.json.${RESET}"
  curl --progress-bar -o ./solr/data/finetuned-products-vectors-4.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-finetuned-vectors-2023-06/finetuned-products-vectors-4.json
fi

for f in $DATA_DIR/finetuned-products-vectors*.json;
  do
    echo "Populating products from ${f}, please give it a few minutes!"
    # The vector documents are large (about 70KB each), so use smaller batches
    ./solr/index-json.sh "$f" 500
   done;
