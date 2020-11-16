<img src="assets/chorus-logo.png" alt="Chorus Logo" width="200"/>

Chorus
==========================

Towards an open source tool stack for e-commerce search.

# What Runs Where

* Demo "Chorus Electronics" store runs at http://localhost:4000  |  http://chorus.dev.o19s.com:4000
* Solr runs at http://localhost:8983 |  http://chorus.dev.o19s.com:8983
* SMUI runs at http://localhost:9000 |  http://chorus.dev.o19s.com:9000
* Quepid runs at http://localhost:3000 |  http://chorus.dev.o19s.com:3000
* RRE runs at http://localhost:7979 |  http://chorus.dev.o19s.com:7979

Working with macOS?   Pop open all the relevant sites:
> open http://localhost:4000 http://localhost:8983 http://localhost:9000 http://localhost:3000 http://localhost:7979


# Learning all about Chorus!

We are trying to strike a balance between making the setup process as easy and fool proof as possible with the need to not _hide_ too much of the interactions between the projects that make up Chorus.

If you are impatient, we have a quick start script, `./quickstart.sh` that sets you up, however I recommend you go through [Kata 0: Setting up Chorus](katas/000_setting_up_chorus.md).   

After that, you can learn how to use the tools in Chorus to improve search in [First Kata: Lets Optimize a Query](katas/001_optimize_a_query.md).




# Useful Commands for Chorus

To start your environment, i.e to do each step manually, run:
```
docker-compose up --build -d
```
Otherwise you can just run `./quickstart.sh`.

To see what is happening in the Chorus stack you can tail the logs for all the components via:
```
docker-compose logs -tf
```

If you want to narrow down to just one component of the Chorus stack do:
```
docker-compose ps                       # list out the names of the components
docker-compose logs -tf solr1 solr2     # tail solr1 and solr2 only
```

To reset your environment (including any volumes created like the mysql db), just run:
```
docker-compose down -v
```

If Docker is giving you a hard time then some options are:
```
docker system prune                     # removes orphaned images, networks, etc.
docker system prune -a --volumes        # removes all images, clears out your Docker diskspace if you full.
```

You may also have to [increase the resources](./assets/increase_docker_resources.gif) given to Docker, up to 4 GB RAM and 2 GB Swap space.


# Sample Data Details

The product data is gratefully sourced from [Icecat](https://icecat.biz/) and is licensed under their Open Content License.
Find out more about the license at https://iceclog.com/open-content-license-opl/.

The version of the open content data that Chorus provides has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
* Prices extracted for ~19,000 products from the https://www.upcitemdb.com/ service using EAN codes to match.
