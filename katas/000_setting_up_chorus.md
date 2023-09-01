# Kata 000: Setting up Chorus

<i><a href="https://opensourceconnections.com/blog/2020/07/20/how-does-pete-the-e-commerce-search-engine-product-manager-build-a-web-shop/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

We use a Docker Compose based environment to manage firing up all the components of the Chorus stack, but then have you go through loading the data and configuring the components.

Open up a terminal window and run:

```sh
docker-compose up --build
```

Wait a while, because you'll be downloading and building quite a few images!  You may think it's frozen at various points, but go for a walk and come back and it'll be up and running.

Now we need to load our product data into Chorus.  Open a second terminal window, so you can see how as you work with Chorus how the various system respond.  

Firstly, we're using SolrCloud, so this means a few more steps to set up our `ecommerce` collection, because we are using the management APIs to set up a new collection.  We're also making sure we start with security baked in from the beginning.  Trust me, this is the right way to do it!  

**Note:** To make Keycloak work, you need to add the following line to your hosts file (/etc/hosts on Mac/Linux, c:\Windows\System32\Drivers\etc\hosts on Windows).

```
127.0.0.1	keycloak
```

This is because you will access your application with a browser on your machine (which is named localhost, or 127.0.0.1), but inside Docker it will run in its own container, which is named keycloak.

Run these steps:

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

We now have a two shard `ecommerce` collection.

Before we index some data we are defining some parameters that define our basic relevancy algorithms using ParamSets:

```sh
curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/config/params -H 'Content-type:application/json'  -d '{
  "set": {
    "visible_products":{
      "fq":["price:*", "-img_500x500:\"\""]
    }
  },
  "set": {
    "default_algo":{
      "defType":"edismax",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "mustmatchall_algo":{
      "deftype":"edismax",
      "mm":"100%",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "querqy_algo":{
      "defType":"querqy",
      "querqy.rewriters":"replace,common_rules,regex_screen_protectors",
      "querqy.infoLogging":"on",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
  "set": {
    "querqy_algo_prelive":{
      "defType":"querqy",
      "querqy.rewriters":"replace_prelive,common_rules_prelive,regex_screen_protectors",
      "querqy.infoLogging":"on",
      "qf": "id name title product_type short_description ean search_attributes"
    }
  },
}'
```

Grab a sample dataset of 150K products by running from the root of your Chorus checkout:

```sh
wget https://querqy.org/datasets/icecat/icecat-products-150k-20200809.tar.gz
```

If you are on a Linux type system, you should be able to stream the data right from the .tar.gz file:

```sh
tar xzf icecat-products-150k-20200809.tar.gz --to-stdout | curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @- -H 'Content-type:application/json'
```

Otherwise you'll need to uncompress the .tar.gz file and then post with Curl:

```sh
gunzip -c icecat-products-150k-20200809.tar.gz | tar xopf -
# For Mac OS
curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @icecat-products-150k-20200809.json -H 'Content-type:application/json'
```

The sample data will take a couple of minutes (like 5!) to load.

You can confirm that the data is loaded by visiting http://localhost:8983/solr/#/ecommerce/core-overview and doing some queries.

However, even better is our mock Ecommerce store, `Chorus Electronics`, available at http://localhost:4000/.  Try out the various facets, and the sample queries, like `coffee`.   

We also need to setup in SMUI the the name of the index we're going to be doing active search management for.  We do this via

```sh
curl -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index
```

Grab the `returnId` from the response, something like `3f47cc75-a99f-4653-acd4-a9dc73adfcd1`, you'll need it for the next steps!

```sh
export SOLR_INDEX_ID=5bc6e917-33b7-45ec-91ba-8e2c4a2e8085
curl -X PUT -H "Content-Type: application/json" -d '{"name":"product_type"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
curl -X PUT -H "Content-Type: application/json" -d '{"name":"title"}' http://localhost:9000/api/v1/${SOLR_INDEX_ID}/suggested-solr-field
```

Now go ahead and confirm that SMUI is working by visiting http://localhost:9000.  We'll learn more about using SMUI later, however test that it's working by clicking the `Publish to LIVE` button.  You will get a confirmation message that the rules were deployed.


Now we want to pivot to setting up our Offline Testing Environment.  Today we have two open source projects integrated into Chorus: Quepid and Rated Ranking Evaluator (RRE).

We'll start with Quepid and then move on to RRE.

First we need to create the database for Quepid:

```sh
docker-compose run --rm quepid bin/rake db:setup
```

We also need to create you an account with Administrator permissions:

```sh
docker-compose run quepid thor user:create -a admin@choruselectronics.com "Chorus Admin" password
```

Visit Quepid at http://localhost:3000 and log in with the email and password you just set up.

Go through the initial case setup process.  Quepid will walk you through setting up a `Movie Cases` case via a Wizard interface, and then show you some of the key features of Quepid's UI.  I know you want to skip the tour of Quepid interface, however there is a lot of interactivity in the UI, so it's worth going through the tutorial to get acquainted!

Now, let's go ahead and make sure we publish the results of our evaluation:


Bring up http://localhost:7979 and you will see a relatively unexciting empty dashboard.  Don't worry, in our first kata, we'll do a relevancy test and fill this dashboard in.

Last but not least we want to set up what we need to monitor our end user facing applications. We use Prometheus and Grafana for this task. Prometheus is already collecting and storing data. For Grafana we need to set up a user and grant this user administrative rights in Grafana:

```sh
curl -u admin:password -S -X POST -H "Content-Type: application/json" -d '{"email":"admin@choruselectronics.com", "name":"Chorus Admin", "role":"admin", "login":"admin@choruselectronics.com", "password":"password", "theme":"light"}' http://localhost:9091/api/admin/users
curl -u admin:password -S -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://localhost:9091/api/admin/users/2/permissions
curl -u admin:password -S -X POST -H "Content-Type: application/json" http://localhost:9091/api/users/2/using/1
```

Check if Grafana is up and running and the freshly created user has access by logging into Grafana at http://localhost:9091 using the username `admin@choruselectronics.com` with the password `password`. We'll dive into the details of observability in [Kata 003 Observability in Chorus](katas/003_observability_in_chorus.md).

Congratulations! You now have Chorus successfully running with its components!
