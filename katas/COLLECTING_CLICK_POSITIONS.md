This notional kata is about how do we actually go about collecting the all important click position!  We need to know both what documents users have seen, as well as what they click on.

The first thing we are going to learn about is a little known Solr search component, the `responseLog`, which lets us write out to the Solr logging files what documents are being returned as a list of id's.  

We can actually add this component to Solr via the config API:

> curl -X POST -H 'Content-type:application/json' -d '{
  "add-searchcomponent": {
    "name": "responselog",
    "class": "org.apache.solr.handler.component.ResponseLogComponent"
  }
}' http://localhost:8983/solr/ecommerce/config

We then need to update our request handlers.  This can be kind of verbose because we are repeating a lot of parameters.   (Maybe we should break this out to it's own set of shared parameters??)

> curl -X POST -H 'Content-type:application/json' -d '{
  "update-requesthandler": {
    "name": "/querqy-select",
    "class": "solr.SearchHandler"
    "defaults": {
      "echoParams": explicit,
      "indent": true,
      "df": "id",
      "qf": "name title product_type short_description ean search_attributes",
      "defType": "querqy",
      "tie": 0.01,
      "mm": "100%",
      "responseLog": true
      },
    "last-components": ["responselog"]
  }
}' http://localhost:8983/solr/ecommerce/config

Notice that in the Solr log output you have a new parameter `responseLog`:

```
 responseLog=77858795,77858796,2368581,4143479,4143572,1768024,1766562,1768012,1679564,3797265,4011117,1418538,78847062,78847065,2500960,1229074,1229111,2273010,1715314,1739387,3186555,3753984,1627958,53884,1751314,2060449,3429328,869847,3917181,643252 status=0 QTime=42
````

So, what happens if you index the data?

https://github.com/apache/lucene-solr/blob/visual-guide/solr/solr-ref-guide/src/logs.adoc

ON THE PLAYING WITH STREAMING SETUP
> docker exec solr1 solr create_collection -c logs -p 8983 -shards 3

Checking the dashboard, it appears that Solr is logging to `-Dsolr.log.dir=/var/solr/logs`.   

> docker-compose run solr bin/postlogs

> docker-compose run solr bin/postlogs http://host.docker.internal:9983/solr/logs /user/foo/logs/solr.log
