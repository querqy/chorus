docker-compose down -v
docker-compose up -d --build keycloak

sleep 30

docker-compose up -d --build zoo1 zoo2 zoo3

#docker cp ./solr/security.json solr1:/security.json
docker-compose up -d --build solr1

docker exec solr1 solr zk cp /opt/querqy/lib/security.json zk:security.json -z zoo1:2181

docker-compose up -d --build solr2 solr3
