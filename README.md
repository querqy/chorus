Chorus
==========================

Your offline and online search solution!

# What is Chorus

# What Runs Where

* Demo "Store" runs at http://localhost:4000
* Solr runs at http://localhost:8983
* SMUI runs at http://localhost:9000
* Quepid runs at http://localhost:3000
* RRE runs at http://localhost:7979

Working with macOS?   Pop open all the relevant sites:
> open http://localhost:4000 http://localhost:8983 http://localhost:9000 http://localhost:3000 http://localhost:7979

# Script to Follow

## Getting Set Up.

We use a Docker Compose based environment to easily set up Chorus.

First run:
> docker-compose up --build

Wait a while, because you'll be downloading quite a few images!


Now we need to load our product data into Chorus.  Grab a sample dataset of 150K products via:

> wget https://querqy.org/datasets/icecat/icecat-products-150k-20200607.tar.gz

If you are on a Linux type system, you should be able to stream the data right .tar.gz file:

> tar xzf icecat-products-150k-20200607.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @- -H 'Content-type:application/json'

Otherwise you'll need to uncompress the .tar.gz and then post with Curl:

> curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @icecat-products-150k-20200607.tar.gz -H 'Content-type:application/json'


You can test that it's working by visiting http://localhost:8983/solr/ecommerce/select?q=*:*.  If you are impatient issue a http://localhost:8983/solr/ecommerce/update?commit=true to trigger a commit.

We also need to setup in SMUI the index we're going to be maintaining.  We do this via

> curl -X PUT -H "Content-Type: application/json" -d '{"name":"ecommerce", "description":"Ecommerce Demo"}' http://localhost:9000/api/v1/solr-index

Grab the `returnId` from the response, something like `3f47cc75-a99f-4653-acd4-a9dc73adfcd1`, you'll need it later!

Now we want to pivot to setting up our Offline Testing Environment.  Today we have two open source projects integrated into Chorus, Quepid and Rated Ranking Evaluator (RRE).

We'll start with Quepid and then move on to RRE.

The very first time you et up Quepid you need to create the database:

> docker-compose run --rm quepid bin/rake db:setup

To setup Quepid we first need to create you an account with Administrator permissions:

> docker-compose run quepid thor user:create -a demo@example.com "Your Name" password

Then log into Quepid at http://localhost:3000 and log in with the email and password you just set up.

Go through the initial case setup process, however change the name of the case to `Ecommerce Search` and use our ecommerce search index instead of the TMDB index that is recommended: `http://localhost:8983/solr/ecommerce/select`



> curl -X PUT -H "Content-Type: application/json" -d '{"name":"Brand_attr"}' http://localhost:9000/api/v1/5d1f55eb-a2a4-4ec2-89d0-9ca693356e33/suggested-solr-field

Now jump to http://localhost:9000

### Looking at DB:

So, connect to your `smui_db` via localhost:3306, with username root, and password password.

### Rules Integration with Solr

Everytime you write out the `rules.txt` it is saved to the mounted volume `./volumes/preliveCore/conf/rules.txt`

This same volume is mounted into the Solr container as `/opt/mysolrhome/ecommerce/conf/querqy`, and Solr
reads it in from there.

The SMUI _Push Config to Solr_ just writes the file out, and then reloads the Solr core, and then Solr reads in the new file.  FTW!

## Loading Data into Solr

> curl 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @solr/products.json -H 'Content-type:application/json'


We created a custom update processor to deal with date formats via:
```
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

Create a user with the email _demo@example.com_ and the password _password_:
> docker-compose run quepid thor user:create -a demo@example.com "Demo User" password

For Quepid case, pick _name_ for title, and _id_ for identifier.  Add _thumb:imageUrl_ to the list of fields.

## Setting up RRE


> docker-compose run rre mvn rre:evaluate

> docker-compose run rre mvn rre-report:report

# Sample Data Details

The product data is gratefully sourced from [Icecat](https://icecat.biz/) and is licensed under their Open Content License.
Find out more about the license at https://iceclog.com/open-content-license-opl/.

The version of the open content data that Chorus provides has the following changes:
* Data converted to JSON format.
* Products that don't have a 500x500 pixel image listed are removed.
