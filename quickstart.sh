#!/bin/bash

# This script starts up Chorus and runs through the basic setup tasks.

set -e

# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
RESET='\033[0m' # No Color

if ! [ -x "$(command -v docker-compose)" ]; then
  echo '${ERROR}Error: docker-compose is not installed.${RESET}' >&2
  exit 1
fi

observability=false

while [ ! $# -eq 0 ]
do
	case "$1" in
		--help | -h)
			echo -e "Use the option --with-observability | -o to include Grafana, Prometheus, and Solr Exporter services in Chorus."
			exit
			;;
		--with-observability | -o)
			observability=true
      echo -e "${MAJOR}Running Chorus with observability services enabled${RESET}"
			;;
	esac
	shift
done

services="quickstart blacklight solr1 solr2 solr3 smui quepid rre"
if $observability; then
  services="${services} grafana solr-exporter"
fi

docker-compose down -v
docker-compose up -d --build ${services}

docker-compose run quickstart /quickstart/setup-solr-cluster.sh

docker-compose run quickstart /quickstart/setup-smui.sh

echo -e "${MAJOR}Setting up Quepid${RESET}"
docker-compose run --rm quepid bin/rake db:setup
docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password

echo -e "${MAJOR}Setting up RRE${RESET}"
docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report

if $observability; then
  docker-compose run quickstart /quickstart/setup-observability.sh
fi

echo -e "${MAJOR}Welcome to Chorus!${RESET}"
