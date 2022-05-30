[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fquerqy%2Fchorus%2Fbadge%3Fref%3Dmain&style=flat)](https://actions-badge.atrox.dev/querqy/chorus/goto?ref=main)


<img src="assets/chorus-logo.png" alt="Chorus Logo" title="Chorus: Towards a open stack for ecommerce search" width="200" align="right"/>

Chorus
==========================

*Towards an open source tool stack for e-commerce search*

Chorus makes deploying powerful ecommerce search easier by shifting the **buy vs build** decision in favour of **build**, so you can own your search! It deals with three issues:

1. **Starting from Scratch is Time Consuming** Downloading a open source search engine isn't enough, it's like getting the parts of a Lego model, only without the directions ;-) .  We need a better baseline to quickly get started.  

2. **Integration of Tooling is Hard** Search isn't just the index, it's also the analytics tooling, the relevance tooling, the operational monitoring that goes into it.  Every team starts incurs the penalty of starting from scratch integrating the ecosystem of options.

3. ***Sharing Knowledge is a Must!*** It isn't enough to just have conference talks, we need sample code and sample data in order to share knowledge about improving ecommerce search. Chorus is that public environment that you can use to share your next great idea!


[Explore a demo](https://github.com/querqy/chorus#what-runs-where), watch [a video about the project](https://www.youtube.com/watch?v=aoWx7KJzvCs) or try it out by [running the quickstart.sh script](#5-minutes-to-run-chorus).   Go deeper by watching the [six part series _Meet Pete_](https://opensourceconnections.com/blog/2020/07/07/meet-pete-the-e-commerce-search-product-manager/).

Want to stay up-to-date with the community? Visit https://querqy.org/ to learn more, and join the [E-Commerce Search Slack](https://ecom-search.slack.com/) group for tips, tricks and news on what's new in the Chorus ecosystem.

## News
 * 23 March 2022: [Chorus, now also for Elasticsearch!](https://opensourceconnections.com/blog/2022/03/23/chorus-now-also-for-elasticsearch/)
 * 17th June 2021: [Encores? - Going beyond matching and ranking of search results](https://www.slideshare.net/o19s/encores) - Chorus is used at BerlinBuzzwords.
 * 15th November 2020: [Chorus Workshop Series Announced](https://plainschwarz.com/ps-salon/) - Learn from the creators of the components of Chorus via six workshops.
 * 17th October 2020: [Chorus featured at ApacheCon @Home](https://www.youtube.com/watch?v=NGtmSbOoFjA) - René and Eric give a talk at ApacheCon on Chorus.
 * 10th June 2020: [Chorus Announced at BerlinBuzzwords](https://2020.berlinbuzzwords.de/session/towards-open-source-tool-stack-e-commerce-search) - First release of Chorus shared with the world at a workshop.
 * April 2020: [Paul Maria Bartusch](https://twitter.com/paulbartusch), [René Kriegler](https://twitter.com/renekrie), [Johannes Peter](https://github.com/JohannesDaniel) & [Eric Pugh](https://twitter.com/dep4b) brainstorm challenges with search teams adopting technologies like Querqy and come up with the Chorus idea.



# What Runs Where
We host a complete demonstration environment online for you to play with, see links below.  _Please note the Demo store isn't always available_.

* "Chorus Electronics" store runs at http://localhost:4000  |  http://chorus.dev.o19s.com:4000
* Solr runs at http://localhost:8983 |  http://chorus.dev.o19s.com:8983
* SMUI runs at http://localhost:9000 |  http://chorus.dev.o19s.com:9000
* Quepid runs at http://localhost:3000 |  http://chorus.dev.o19s.com:3000
* RRE runs at http://localhost:7979 |  http://chorus.dev.o19s.com:7979
* Keycloak runs at http://keycloak:9080 |  http://chorus.dev.o19s.com:9080
* Prometheus runs at http://localhost:9090 |  http://chorus.dev.o19s.com:9090
* Grafana runs at http://localhost:9091 |  http://chorus.dev.o19s.com:9091

Working with macOS?   Pop open all the tuning related web pages with one terminal command:
> open http://localhost:4000 http://localhost:8983 http://localhost:9000 http://localhost:3000 http://localhost:7979


# 5 Minutes to Run Chorus!

We are trying to strike a balance between making the setup process as easy and fool proof as possible with the need to not _hide_ too much of the interactions between the projects that make up Chorus.

If you are impatient, we have a quick start script, `./quickstart.sh` that sets you up, however I recommend you go through [Kata 0: Setting up Chorus](katas/000_setting_up_chorus.md).   

# Structured Learning using Chorus

After that, you can learn about how to use all the tools in Chorus to improve search by following these Katas:

1. First Kata: [Lets Optimize a Query](katas/001_optimize_a_query.md)
1. Second Kata: [How to Sell Search Keywords and Terms](katas/002_how_to_sell_search_keywords.md)
1. Kata 003: [Observability in Chorus](katas/003_observability_in_chorus.md)
1. Fourth Kata: [How to Gather Human Judgements](katas/004_gathering_human_judgements.md)
1. Fifth Kata: [Some days you just KNOW what the right products are for a query!](katas/005_curating_specific_products_for_a_query.md)
1. Sixth Kata: [Adding Custom Rules to Querqy!](katas/006_adding_custom_query_rules.md)
1. Seventh Kata: [Name you Algorithms using ParamSets](katas/007_organize_algorithms_using_paramsets.md)
1. Eighth Kata: [Previewing Rules Before Users See Them](katas/008_previewing_your_querqy_rules_in_production.md)
1. Ninth Kata: [Organize your queries using Tags](katas/009_tagging_your_queries.md)

There is also a video series that is very closely related called [Meet Pete](https://opensourceconnections.com/blog/2020/07/07/meet-pete-the-e-commerce-search-product-manager/)



# Useful Commands for Chorus

To start your environment, but still run each command to setup the integrations manually, run:

```
docker-compose up --build -d
```

The quickstart command will launch a Solr cluster, load the configsets and product data for the _ecommerce_ index, and launch the SMUI user interface:

```
./quickstart.sh
```

If you want to add in the offline lab environment based on Quepid, then tack on the `--with-offline-lab` parameter:

```
./quickstart.sh --with-offline-lab
```

To include the observability features, run:

```
./quickstart.sh --with-observability
```

To see what is happening in the Chorus stack you can tail the logs for all the components via:
```
docker-compose logs -tf
```

If you want to narrow down to just one component of the Chorus stack do:
```
docker-compose ps                       # list out the names of the components
docker-compose logs -tf solr1 solr2     # tail solr1 and solr2 only
```

To destroy your environment (including any volumes created like the mysql db), just run:
```
docker-compose down -v
```

or

```
./quickstart.sh --shutdown
```

If Docker is giving you a hard time then some options are:
```
docker system prune                     # removes orphaned images, networks, etc.
docker system prune -a --volumes        # removes all images, clears out your Docker diskspace if you full.
```

You may also have to [increase the resources](./assets/increase_docker_resources.gif) given to Docker, up to 4 GB RAM and 2 GB Swap space.


# Chorus Data Details

The Chorus project includes some public datasets.  These datasets let the community learn, experiment, and collaborate in a safe manner and are a key part of demonstrating how to build measurable and tunable ecommerce search with open source components.

The product data is gratefully sourced from [Icecat](https://icecat.biz/) and is licensed under their [Open Content License](https://iceclog.com/open-content-license-opl/).

The version of the Icecat product data that Chorus [provides](https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz) has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
* Prices extracted for ~19,000 products from the https://www.upcitemdb.com/ service using EAN codes to match.

The ratings data (a.k.a explicit judgements) allows you to measure the impact of your changes to relevance.   We are profoundly grateful
to the team at [Supahands](http://www.supahands.com/) for voluntarily generating multiple ratings for the set of 125 representative ecommerce queries and
sharing that data with the Chorus community:
* [Broad_Query_Set_rated.csv](./katas/Broad_Query_Set_rated.csv) - Query/Doc/Rating set suitable for measuring experiments.
* [Broad_Query_Set_individual_ratings.csv](./katas/Broad_Query_Set_individual_ratings.csv) - Raw ratings generated by the three individual SupaAgents per query.

Learn more in [Kata 006: How to Use Explicit Judgements](./katas/something.md) about how you can work with Supahands to generate your human judgements.
