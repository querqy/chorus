### Accounts Setup

| Component | Username                    | Password  | Origin             |
|-----------|-----------------------------|-----------|--------------------|
| Solr      | admin@choruselectronics.com | password  | chorus-realm.json  |
| Solr      | admin                       | password  | security.json      |
| Solr      | solr                        | SolrRocks | security.json      |
| Quepid    | admin@choruselectronics.com | password  | chorus-realm.json      |
| Quepid    | admin@choruselectronics.com | password  | quickstart.sh      |
| Grafana   | admin@choruselectronics.com | password  | quickstart.sh      |
| Keycloak  | admin                       | password  | docker-compose.yml |
| MySQL     | root                        | password  | docker-compose.yml |


`blockUnknown` is false as we want to let RRE (now removed from Chorus) run against the `ecommerce` collection.  We have locked down in `security.json` to allow anonymous users only to hit the /ecommerce/select/ end point

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
docker compose run quepid bundle exec thor user:create -a demo@example.com "Demo User" password
```

For Quepid case, pick `name` for title, and `id` for identifier.  Add `thumb:imageUrl` to the list of fields.

## Monitoring Details

Prometheus and Grafana setup heavily inspired by https://github.com/vegasbrianc/prometheus and https://github.com/chatman/solr-grafana-docker

* https://grafana.com/docs/grafana/latest/administration/configure-docker/

The Solr dashboard `/grafana/provisioning/dashboards/solr-dashboard_rev8.json` was rebuilt for Solr 10's native
Prometheus metrics (the earlier revisions targeted the removed solr-exporter) and uses the `Prometheus` datasource directly.

We imported the dashboard https://grafana.com/grafana/dashboards/10306 for Rails.   Could not get Puma metrics to be gathered by
prometheus however.

We created `admin@choruselectronics.com` / `password` in `quickstart.sh`.

The Blacklight prometheus exporter runs at http://localhost:9394/metrics. Solr serves Prometheus metrics natively at
http://localhost:8983/solr/admin/metrics (and on 8984, 8985 for the other nodes); Prometheus scrapes all three nodes.

The monitoring should probably be on it's own network ;-)

## Jaeger for distributed Tracing Details

The tracing in Solr is set up for demo purposes, using `OTEL_TRACES_SAMPLER=parentbased_always_on` (set by
`quickstart.sh --with-observability`, otherwise `always_off`) only makes sense in a toy deployment!

Solr uses its `opentelemetry` module and sends traces via OTLP (HTTP/protobuf, port 4318) to Jaeger, however for Blacklight
we still use the Jaeger HTTP exporter for pushing data to Jaeger.

## Keycloak

Lots going on here!   We have migrated to the Quarkus version, which promises better startup times, but
we don't use the production version, so we get a 12 second start up penalty ;-(.

https://github.com/eabykov/keycloak-compose for ideas.

Keycloak in non localhost wants SSL, so make sure to disable it in the administration tool.

```
In the "master" realm, over login tab. Change 'Require SSL' property to none.
```
To update our Keycloak set up (like add new users or clients) the pattern we've used is to just log into the Keycloak UI and make the changes.   Then, use Docker CLI to log in, and use the `kc.sh`:

`./kc.sh export --users realm_file --dir /opt/keycloak/data/export/`

Then cat the contents of `/opt/keycloak/data/export/chorus-realm.json` and paste it into our local copy of the file.
