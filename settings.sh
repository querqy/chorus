#!/bin/bash

# This script is sourced by quickstart.sh and quickstop.sh
export DOCKER_SCAN_SUGGEST=false
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export DOCKER_DEFAULT_PLATFORM2=linux/amd64
export DOCKER_AMD64_PLATFORM=linux/amd64

offline_lab=false
observability=false
local_deploy=true
vector_search=false
active_search_management=false
shutdown=false
apple_silicon=false

SOLR_USER=solr
SOLR_PASS=SolrRocks