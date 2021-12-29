# Kata 000: Setting up Chorus

<i><a href="https://opensourceconnections.com/blog/2020/07/20/how-does-pete-the-e-commerce-search-engine-product-manager-build-a-web-shop/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

We use a Docker Compose based environment to manage firing up all the components of the Chorus stack, but then have you go through loading the data and configuring the components.

Open up a terminal window and run:
> docker-compose up --build

Wait a while, because you'll be downloading and building quite a few images!  You may think it's frozen at various points, but go for a walk and come back and it'll be up and running.

Now we need to load our product data into Chorus.  Open a second terminal window, so you can see how as you work with Chorus how the various system respond.  

Firstly, we're using SolrCloud, so this means a few more steps to set up our _ecommerce_ collection, because we are using the management APIs to set up a new collection.  We're also making sure we start with security baked in from the beginning.  Trust me, this is the right way to do it!  Run these steps:

```
docker cp ./solr/security.json solr1:/security.json
docker exec solr1 solr zk cp /security.json zk:security.json -z zoo1:2181

(cd solr/configsets/ecommerce/conf && zip -r - *) > ./solr/configsets/ecommerce.zip
curl  --user solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @./solr/configsets/ecommerce.zip "http://localhost:8983/api/cluster/configs/ecommerce"

curl --user solr:SolrRocks -X POST http://localhost:8983/api/collections -H 'Content-Type: application/json' -d'
  {
    "create": {
      "name": "ecommerce",
      "config": "ecommerce",
      "numShards": 2,
      "replicationFactor": 1,
      "waitForFinalState": true
    }
  }
'
```

We now have a two shard _ecommerce_ collection

Grab a sample dataset of 150K products by running from the root of your Chorus checkout:

> wget https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz

If you are on a Linux type system, you should be able to stream the data right from the .tar.gz file:

> tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'

Otherwise you'll need to uncompress the .tar.gz file and then post with Curl:

> gunzip -c icecat-products-150k-20200809.tar.gz | tar xopf - #For Mac OS
> curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @icecat-products-150k-20200809.json -H 'Content-type:application/json'

The sample data will take a couple of minutes (like 5!) to load.

You can confirm that the data is loaded by visiting http://localhost:8983/solr/#/ecommerce/core-overview and doing some queries.

However, even better is our mock Ecommerce store, _Chorus Electronics_, available at http://localhost:4000/.  Try out the various facets, and the sample queries, like _coffee_.   

We also need to setup in SMUI the the name of the index we're going to be doing active search management for.  We do this via

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index

Grab the `returnId` from the response, something like `3f47cc75-a99f-4653-acd4-a9dc73adfcd1`, you'll need it for the next steps!

> export SOLR_INDEX_ID=5bc6e917-33b7-45ec-91ba-8e2c4a2e8085

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field

Now go ahead and confirm that SMUI is working by visiting http://localhost:9000.  We'll learn more about using SMUI later, however test that it's working by clicking the _Publish to LIVE_ button.  You will get a confirmation message that the rules were deployed.


Now we want to pivot to setting up our Offline Testing Environment.  Today we have two open source projects integrated into Chorus: Quepid and Rated Ranking Evaluator (RRE).

We'll start with Quepid and then move on to RRE.

First we need to create the database for Quepid:

> docker-compose run --rm quepid bin/rake db:setup

We also need to create you an account with Administrator permissions:

> docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password

Visit Quepid at http://localhost:3000 and log in with the email and password you just set up.

Go through the initial case setup process.  Quepid will walk you through setting up a _Movie Cases_ case via a Wizard interface, and then show you some of the key features of Quepid's UI.  I know you want to skip the tour of Quepid interface, however there is a lot of interactivity in the UI, so it's worth going through the tutorial to get acquainted!

Now we are ready to confirm our second Offline Testing tool, Rated Ranking Evaluator, commonly called RRE, is ready to go.  Unlike Quepid, which is a webapp, RRE is a set of command line tools that run tests, and then publishes the results in both a Excel spreadsheet format and a web dashboard.   

Now, lets confirm that you can run the RRE command line tool.  Go ahead and run a regression:  

> docker-compose run rre mvn rre:evaluate

You should see some output, and you should see the output saved to `./rre/target/rre/evaluation.json` in your local directory.  We've wrapped RRE inside of the Docker container, so you can edit the RRE configurations locally, but run RRE in the container.

Now, let's go ahead and make sure we publish the results of our evaluation:

> docker-compose run rre mvn rre-report:report

You can now see a Excel spreadsheet saved to `./rre/target/site/rre-report.xlsx`.  

Bring up http://localhost:7979 and you will see a relatively unexciting empty dashboard.  Don't worry, in our first kata, we'll do a relevancy test and fill this dashboard in.
