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

> open http://chorus.dev.o19s.com:4000 http://chorus.dev.o19s.com:8983 http://chorus.dev.o19s.com:9000 http://chorus.dev.o19s.com:3000 http://chorus.dev.o19s.com:7979

# Learning all about Chorus!

We are trying to strike a balance between making the setup process as easy and fool proof as possible with the need to not _hide_ too much of the interactions between the projects that make up Chorus.

If you are impatient, we have a quick start script, `./quickstart.sh` that sets you up, however I recommend you go through [Kata 0: Setting up Chorus](kata/001_optimize_a_query.md).   

After that, you can learn how to use the tools in Chorus to improve search in [First Kata: Lets Optimize a Query](kata/001_optimize_a_query.md).




# How to restart

To reset your environment, just run:
```
docker-compose down -v
git checkout volumes/preliveCore/conf/rules.txt
```

Note: this will reset the MySQL database, and then reset you Querqy rules.



# Sample Data Details

The product data is gratefully sourced from [Icecat](https://icecat.biz/) and is licensed under their Open Content License.
Find out more about the license at https://iceclog.com/open-content-license-opl/.

The version of the open content data that Chorus provides has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
* Prices extracted for ~19,000 products from the https://www.upcitemdb.com/ service using EAN codes to match.
