# This script starts up Chorus and runs through the basic setup tasks.

docker-compose down -v
docker-compose up -d --build --platform=linux quickstart blacklight solr1 solr2 solr3 smui quepid rre grafana solr-exporter

docker-compose run quickstart /quickstart/setup-solr-cluster.sh

docker-compose run quickstart /quickstart/setup-smui.sh

docker-compose run --rm quepid bin/rake db:setup
docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password

docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report

docker-compose run quickstart /quickstart/setup-observability.sh
