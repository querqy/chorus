# Chorus Electronics web shop

The [Blacklight](https://github.com/projectblacklight/blacklight) front end for Chorus, served at http://localhost:4000
by `docker compose` (see `quickstart.sh`). It talks to the `ecommerce` collection in Solr through `SOLR_URL`.

* Blacklight 9 on Rails 8, with Propshaft and importmaps, so no Node.js build step is needed.
* `app/controllers/catalog_controller.rb` holds the search configuration, including one search field per relevance
  algorithm ParamSet in Solr.
* `app/components/search_header_component.rb` adds the Querqy REDIRECT handling and the product type pills.
* Traces go to Jaeger via OpenTelemetry (OTLP), and `prometheus_exporter` serves metrics on port 9394.
