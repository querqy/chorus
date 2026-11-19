#!/bin/bash
# Posts a JSON array of documents to Solr in batches, so that no single request, or the stream that forwards
# documents between the Solr nodes, has to carry the whole file. Each batch is retried, and the script stops
# with Solr's error if a batch keeps failing.
#
# usage: solr/index-json.sh FILE|- [BATCH_SIZE]

set -euo pipefail

SOLR_UPDATE_URL=${SOLR_UPDATE_URL:-http://localhost:8983/solr/ecommerce/update}
SOLR_CREDENTIALS=${SOLR_CREDENTIALS:-solr:SolrRocks}
MAX_ATTEMPTS=3

input=${1:?usage: $0 FILE|- [BATCH_SIZE]}
batch_size=${2:-5000}

batch_dir=$(mktemp -d)
trap 'rm -rf "$batch_dir"' EXIT

# One batch per file, each a JSON array of up to batch_size documents.
# jq writes numbers it passes through unchanged in plain decimal notation, so 1.0866887123484048e-06 would become
# 0.0000010866887123484048. Solr parses such long numbers as strings, which its dense vector fields reject, so we
# have jq write every number as a double again (. + 0), which keeps the short exponent notation.
batches_filter='walk(if type == "number" then . + 0 else . end) | range(0; length; $n) as $i | .[$i:$i + $n]'
if [ "$input" = "-" ]; then
  jq -c --argjson n "$batch_size" "$batches_filter"
else
  jq -c --argjson n "$batch_size" "$batches_filter" "$input"
fi | split -l 1 -a 4 - "$batch_dir/batch_"

batches=("$batch_dir"/batch_*)
docs_sent=0
for i in "${!batches[@]}"; do
  batch=${batches[$i]}
  docs=$(jq length "$batch")
  for attempt in $(seq $MAX_ATTEMPTS); do
    response=$(curl -sS --user "$SOLR_CREDENTIALS" -H 'Content-type:application/json' --data-binary @"$batch" "$SOLR_UPDATE_URL" || true)
    if [ "$(echo "$response" | jq -r '.responseHeader.status' 2>/dev/null)" = "0" ]; then
      break
    fi
    if [ "$attempt" = "$MAX_ATTEMPTS" ]; then
      echo "Batch $((i + 1)) of ${#batches[@]} failed $MAX_ATTEMPTS times:" >&2
      echo "$response" | jq -r '.error.msg // .' 2>/dev/null >&2 || echo "$response" >&2
      exit 1
    fi
    echo "Batch $((i + 1)) of ${#batches[@]} failed, retrying."
    sleep $((attempt * 5))
  done
  docs_sent=$((docs_sent + docs))
  echo "Indexed batch $((i + 1)) of ${#batches[@]} ($docs_sent documents)"
done

curl -sS --fail --user "$SOLR_CREDENTIALS" "$SOLR_UPDATE_URL?commit=true" > /dev/null
echo "Indexed and committed $docs_sent documents."
