### Accounts Setup

| Component | Username                    | Password  | Origin             |
|-----------|-----------------------------|-----------|--------------------|
| Solr      | solr                        | SolrRocks | security.json      |
| Quepid    | admin@choruselectronics.com | password  | quickstart.sh      |
| Grafana   | admin@choruselectronics.com | password  | quickstart.sh      |
| Keycloak  | admin                       | password  | docker-compose.yml |
| MySQL     | root                        | password  | docker-compose.yml |


`blockUnknown` is false as we want to let RRE run against the `ecommerce` collection.  We have locked down in `security.json` to allow anonymous users only to hit the /ecommerce/select/ end point <-- UPDATE this isn't working.

When you bring up Solr Admin and then are redirected to Keycloak, when you register and sent back to Solr you are given the `solr-admin` role.

### Looking at DB:

So, connect to your `smui_db` via `localhost:3306`, with username `root`, and password `password`.

## Loading Data into Solr

```sh
curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @solr/products.json -H 'Content-type:application/json'
```

We created a custom update processor to deal with date formats via:
```sh
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

Create a user with the email `demo@example.com` and the password `password`:
```sh
docker-compose run quepid thor user:create -a demo@example.com "Demo User" password
```

For Quepid case, pick `name` for title, and `id` for identifier.  Add `thumb:imageUrl` to the list of fields.

## Setting up RRE

```sh
docker-compose run rre mvn rre:evaluate
docker-compose run rre mvn rre-report:report
```

## Monitoring Details

Prometheus and Grafana setup heavily inspired by https://github.com/vegasbrianc/prometheus and https://github.com/chatman/solr-grafana-docker

* https://grafana.com/docs/grafana/latest/administration/configure-docker/

We update the `/grafana/provisioning/dashboards/solr-dashboard_rev7.json` to replace `${DS_PROMETHEUS}` with `Prometheus`

We imported the dashboard https://grafana.com/grafana/dashboards/10306 for Rails.   Could not get Puma metrics to be gathered by
prometheus however.

We created `admin@choruselectronics.com` / `password` in `quickstart.sh`.

The two prometheus exporters run at http://localhost:9394/metrics and http://localhost:9854/metrics.

The monitoring should probably be on it's own network ;-)

## Jaeger for distributed Tracing Details

The tracing in Solr is set up for demo purposes, using the `JAEGER_SAMPLER_TYPE=const` and `JAEGER_SAMPLER_PARAM=1` only
makes sense in a toy deployment!  

For Solr we use the UDP method, however for Blacklight we use the HTTP method for pushing data to Jaeger.
We are only part of the way (I think!) to using OpenTelemetry protocols w Jaeger.

## Keycloak

Lots going on here!   We have migrated to the Quarkus version, which promises better startup times, but
we don't use the production version, so we get a 12 second start up penality ;-(.

https://github.com/eabykov/keycloak-compose for ideas.

Keycloak in non localhost wants SSL, so make sure to disable it in the administration tool.

```
In the "master" realm, over login tab. Change 'Require SSL' property to none.
```
