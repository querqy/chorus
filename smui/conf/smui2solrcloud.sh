#!/bin/bash

set -euo pipefail

SRC_TMP_FILE=$1
DST_CP_FILE_TO=$2
SOLR_HOST=$3
SOLR_CORE_NAME=$4
DECOMPOUND_DST_CP_FILE_TO=$5
TARGET_SYSTEM=$6
REPLACE_RULES_SRC_TMP_FILE=$7
REPLACE_RULES_DST_CP_FILE_TO=$8

echo "In smui2solrcloud.sh - script performing rules.txt update and core reload"
echo "^-- SRC_TMP_FILE = $SRC_TMP_FILE"
echo "^-- DST_CP_FILE_TO = $DST_CP_FILE_TO"
echo "^-- SOLR_HOST = $SOLR_HOST"
echo "^-- SOLR_CORE_NAME: $SOLR_CORE_NAME"
echo "^-- DECOMPOUND_DST_CP_FILE_TO = $DECOMPOUND_DST_CP_FILE_TO"
echo "^-- TARGET_SYSTEM = $TARGET_SYSTEM"
echo "^-- REPLACE_RULES_SRC_TMP_FILE = $REPLACE_RULES_SRC_TMP_FILE"
echo "^-- REPLACE_RULES_DST_CP_FILE_TO = $REPLACE_RULES_DST_CP_FILE_TO"

# DEPLOYMENT
#####

echo "^-- Perform rules.txt deployment (decompound-rules.txt eventually)"

# $1 - from_filename
# $2 - to_filename (might be local or remote)
function deploy_rules_txt {

  echo "^-- ... pushing file ${1} to ZK at ${2}"

  java -jar /smui/conf/jackhanna-0.0.4-SNAPSHOT.jar zoo1:2181 putfile --file ${1} --zkFile ${2}

}

echo "^-- ... rules.txt"
#deploy_rules_txt $SRC_TMP_FILE $DST_CP_FILE_TO
python3 /smui/conf/push_common_rules.py $SRC_TMP_FILE "http://$SOLR_HOST/solr/$SOLR_CORE_NAME/querqy/rewriter/common_rules"
if [ $? -ne 0 ]; then
  exit 16
fi



#echo "^-- ... decompound-rules.txt"
#if ! [[ $DECOMPOUND_DST_CP_FILE_TO == "NONE" ]]
#then
#    deploy_rules_txt "$SRC_TMP_FILE-2" $DECOMPOUND_DST_CP_FILE_TO
#fi

echo "^-- ... replace-rules.txt"
if ! [[ $REPLACE_RULES_SRC_TMP_FILE == "NONE" && $REPLACE_RULES_DST_CP_FILE_TO == "NONE" ]]
then
    python3 /smui/conf/push_replace.py $REPLACE_RULES_SRC_TMP_FILE "http://$SOLR_HOST/solr/$SOLR_CORE_NAME/querqy/rewriter/replace"
fi



# all ok
echo "smui2solrcloud.sh - ok"
exit 0
