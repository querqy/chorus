Chorus
==========================

Your offline and online search solution!

# What is Chorus

# What Runs Where

* Demo "Store" runs at http://localhost:4000  |  http://chorus.dev.o19s.com:4000
* Solr runs at http://localhost:8983 |  http://chorus.dev.o19s.com:8983
* SMUI runs at http://localhost:9000 |  http://chorus.dev.o19s.com:9000
* Quepid runs at http://localhost:3000 |  http://chorus.dev.o19s.com:3000
* RRE runs at http://localhost:7979 |  http://chorus.dev.o19s.com:7979

Working with macOS?   Pop open all the relevant sites:
> open http://localhost:4000 http://localhost:8983 http://localhost:9000 http://localhost:3000 http://localhost:7979

# Getting Set Up to Play with Chorus

We are trying to strike a balance between making the setup process as easy and fool proof as possible with the need to not _hide_ too much of the interactions between the projects that make up Chorus.

We use a Docker Compose based environment to manage firing up all the components of the Chorus stack, but then have you go through loading the data and configuring the components.

Open up a terminal window and run:
> docker-compose up --build

Wait a while, because you'll be downloading and building quite a few images!  You may think it's frozen at various points, but go for a walk and come back and it'll be up and running.


Now we need to load our product data into Chorus.  Open a second terminal window, so you can see how as you work with Chorus how the various system respond.  

Grab a sample dataset of 150K products by running from the root of your Chorus checkout:

> wget https://querqy.org/datasets/icecat/icecat-products-150k-20200607.tar.gz

If you are on a Linux type system, you should be able to stream the data right from the .tar.gz file:

> tar xzf icecat-products-150k-20200607.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @- -H 'Content-type:application/json'

Otherwise you'll need to uncompress the .tar.gz file and then post with Curl:

> curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @icecat-products-150k-20200607.tar.gz -H 'Content-type:application/json'

The sample data can take a couple of minutes to load.

You can confirm that the data is loaded by visiting http://localhost:8983/solr/#/ecommerce/core-overview and doing some queries.

However, even better is our mock Ecommerce Search Store, available at http://localhost:4000/.  Try out the various facets, and the sample queries, like _coffee_.   

We also need to setup in SMUI the the name of the index we're going to be doing active search management for.  We do this via

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index

Grab the `returnId` from the response, something like `3f47cc75-a99f-4653-acd4-a9dc73adfcd1`, you'll need it for the next steps!

> export SOLR_INDEX_ID=returnId

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"attr_t_product_type"}' http://localhost:9000/api/v1/{$SOLR_INDEX_ID}/suggested-solr-field

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/{$SOLR_INDEX_ID}/suggested-solr-field

Now go ahead and confirm that SMUI is working by visiting http://localhost:9000.  We'll learn more about using SMUI later, however test that it's working by clicking the _Push Config to Solr_ button.  You will get a confirmation message that the rules were deployed.


Now we want to pivot to setting up our Offline Testing Environment.  Today we have two open source projects integrated into Chorus, Quepid and Rated Ranking Evaluator (RRE).

We'll start with Quepid and then move on to RRE.

First we need to create the database for Quepid:

> docker-compose run --rm quepid bin/rake db:setup

We also need to create you an account with Administrator permissions:

> docker-compose run quepid thor user:create -a demo@example.com "Demo User" password

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


# Sample Data Details

The product data is gratefully sourced from [Icecat](https://icecat.biz/) and is licensed under their Open Content License.
Find out more about the license at https://iceclog.com/open-content-license-opl/.

The version of the open content data that Chorus provides has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
