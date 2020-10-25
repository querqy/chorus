# Kata 003: Observability in Chorus

This Kata is a more technical one, where we learn how to set up some basic tooling to enable _Observability_ for Chorus.
What is Observability you ask?  Checkout this blog post by New Relic as an intro: https://blog.newrelic.com/engineering/what-is-observability/

We're assuming you've run the `quickstart.sh` script, or gone through the steps in [Kata 000 Setting up Chorus](katas/000_setting_up_chorus.md) already.

Since Solr and Blacklight are the primary end user facing applications, we want to monitor them.   We're going to use two open
source projects that are widely deployed in "cloud native" setups, Prometheus which gathers metrics and stores
them, and Grafana, which gives you a really nice dashboard view of that data.   Fortunately there are already some nice dashboards in Grafana for both Solr and Rails (the underlying framework Blacklight is built in) that we've packaged in.

We'll start form the Dashboards in Grafana, and then work our way back to how we get this data.  Log into Grafana at http://localhost:9091 using the username `admin@choruselectronics.com` with the password `password`.   

Pop over to Dashboards icon and Manage, and you'll see _Rails Metrics_ listed.  

From a monitoring the web store perspective, you care about Request Duration, to see which pages are running slow or fast.

Note, we don't have some of the more advanced metrics (scroll down) that you might typically collect from a Rails application being collected from our Blacklight web store.

Now, lets look at Solr.   Pop over to Dashboards icon and Manage, and you'll see _Solr Dashboard_ listed.  

Here you can see lots of low level data, from Jetty web server, to the  JVM and OS metrics being gathered, and whats nice is you can see across our cluster of three Solr nodes running.   

keep going down, past the Node metrics to the Core Metrics, and here you can see details about our setup, for example, the almost 80,000 products that are in the web store.   Go ahead and do some searches, or run the indexing process and you'll see some of the line graphs move up and down.


So where does Grafana get this data from?  Well, pop over to the Prometheus dashboard at http://localhost:9090.  Of interest
is to see Status --> Targets, and see that we're monitoring Solr, Blacklight, and of course Prometheus itself.

We won't get into the graphing capabilities of Prometheus, since we have Grafana for that.   However know that you can set up Alerting behaviors here.

Lastly, so where does the data come into Prometheus?  The Prometheus server actually reaches out and pulls in the data periodically, it doesn't get data pushed to it.  So we have two "Exporters" that run that convert internal metrics to the Prometheus standard:

* Blacklight Metrics: http://localhost:9394/metrics
* Solr Cluster Metrics: http://localhost:9854/metrics

This was just a quick tour, and as we move to Kubernetes for Chorus, the observability aspect to Chorus will become more important!
