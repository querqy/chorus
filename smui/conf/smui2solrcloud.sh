#!/bin/bash

set -euo pipefail

SRC_TMP_FILE=$1
DST_CP_FILE_TO=$2
SOLR_HOST=$3
SOLR_COLLECTION_NAME=$4
DECOMPOUND_DST_CP_FILE_TO=$5
TARGET_SYSTEM=$6
REPLACE_RULES_SRC_TMP_FILE=$7
REPLACE_RULES_DST_CP_FILE_TO=$8

echo "In smui2solrcloud.sh - script deploying rules to Solr for Querqy"
echo "^-- SRC_TMP_FILE = $SRC_TMP_FILE"
echo "^-- DST_CP_FILE_TO = $DST_CP_FILE_TO"
echo "^-- SOLR_HOST = $SOLR_HOST"
echo "^-- SOLR_COLLECTION_NAME: $SOLR_COLLECTION_NAME"
echo "^-- DECOMPOUND_DST_CP_FILE_TO = $DECOMPOUND_DST_CP_FILE_TO"
echo "^-- TARGET_SYSTEM = $TARGET_SYSTEM"
echo "^-- REPLACE_RULES_SRC_TMP_FILE = $REPLACE_RULES_SRC_TMP_FILE"
echo "^-- REPLACE_RULES_DST_CP_FILE_TO = $REPLACE_RULES_DST_CP_FILE_TO"

# DEPLOYMENT
#####

echo "^-- Perform rules.txt deployment (decompound-rules.txt eventually)"

function common_rules_rewriter_url() {
  if [ $TARGET_SYSTEM == "LIVE" ]; then
    URL="http://solr:SolrRocks@$SOLR_HOST/solr/$SOLR_COLLECTION_NAME/querqy/rewriter/common_rules"
  else
    URL="http://solr:SolrRocks@$SOLR_HOST/solr/$SOLR_COLLECTION_NAME/querqy/rewriter/common_rules_prelive"
  fi
}
function replace_rewriter_url() {
  if [ $TARGET_SYSTEM == "LIVE" ]; then
    URL="http://solr:SolrRocks@$SOLR_HOST/solr/$SOLR_COLLECTION_NAME/querqy/rewriter/replace"
  else
    URL="http://solr:SolrRocks@$SOLR_HOST/solr/$SOLR_COLLECTION_NAME/querqy/rewriter/replace_prelive"
  fi
}

echo "^-- ... rules.txt"
common_rules_rewriter_url $1

python3 /smui/conf/push_common_rules.py $SRC_TMP_FILE $URL
if [ $? -ne 0 ]; then
  exit 16
fi

echo "^-- ... replace-rules.txt"
replace_rewriter_url $1
if ! [[ $REPLACE_RULES_SRC_TMP_FILE == "NONE" && $REPLACE_RULES_DST_CP_FILE_TO == "NONE" ]]
then
    python3 /smui/conf/push_replace.py $REPLACE_RULES_SRC_TMP_FILE $URL
fi

# all ok
echo "smui2solrcloud.sh - ok"
exit 0
