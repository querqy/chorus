### Accounts Setup

| Component | Username                    | Password  | Origin             |
|-----------|-----------------------------|-----------|--------------------|
| Solr      | solr                        | SolrRocks | security.json      |
| Quepid    | admin@choruselectronics.com | password  | quickstart.sh      |
| Grafana   | admin@choruselectronics.com | password  | quickstart.sh      |
| Keycloak  | admin                       | password  | docker-compose.yml |
| MySQL     | root                        | password  | docker-compose.yml |
|           |                             |           |                    |
|           |                             |           |                    |


`blockUnknown` is false as we want to let RRE run against the _ecommerce_ collection.  We have locked
down in `security.json` to allow anonymous users only to hit the /ecommerce/select/ end point.

### Looking at DB:

So, connect to your `smui_db` via localhost:3306, with username root, and password password.

### Rules Integration with Solr

Everytime you write out the `rules.txt` it is saved to the mounted volume `./volumes/preliveCore/conf/rules.txt`

This same volume is mounted into the Solr container as `/opt/mysolrhome/ecommerce/conf/querqy`, and Solr
reads it in from there.

The SMUI _Push Config to Solr_ just writes the file out, and then reloads the Solr core, and then Solr reads in the new file.  FTW!

## Loading Data into Solr

> curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @solr/products.json -H 'Content-type:application/json'


We created a custom update processor to deal with date formats via:
```
curl http://localhost:8983/solr/ecommerce/config -H 'Content-type:application/json' -d '
{                                                                               
  "add-updateprocessor" :
  {
    "name" : "formatDateUpdateProcessor",
    "class": "solr.ParseDateFieldUpdateProcessorFactory",
    "format":["yyyy-MM-dd"]
  }
}'
```



## Setting up Quepid

Create a user with the email _demo@example.com_ and the password _password_:
> docker-compose run quepid thor user:create -a demo@example.com "Demo User" password

For Quepid case, pick _name_ for title, and _id_ for identifier.  Add _thumb:imageUrl_ to the list of fields.

## Setting up RRE


> docker-compose run rre mvn rre:evaluate

> docker-compose run rre mvn rre-report:report


## Monitoring Details

Prometheus and Grafana setup heavily inspired by https://github.com/vegasbrianc/prometheus and https://github.com/chatman/solr-grafana-docker

* https://grafana.com/docs/grafana/latest/administration/configure-docker/

We update the /grafana/provisioning/dashboards/solr-dashboard_rev7.json to replace `${DS_PROMETHEUS}` with `Prometheus`

We imported the dashboard https://grafana.com/grafana/dashboards/10306 for Rails.   Could not get Puma metrics to be gathered by
prometheus however.

We created `admin@choruselectronics.com / password` in quickstart.

The two prometheus exporters run at http://localhost:9394/metrics and http://localhost:9854/metrics.

The monitoring should probably be on it's own network ;-)
