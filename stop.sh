#!/bin/bash

# This script stops Chorus.

source settings.sh
source helpers.sh

docker-compose down -v
if $shutdown; then
  exit
fi
