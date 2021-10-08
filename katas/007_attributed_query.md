Query for notebooks that have internal memory attribute.


http://localhost:8983/solr/ecommerce/select?facet.field=attr_n_internal_memory&facet.mincount=1&facet=true&fl=attr_n_internal_memory%2C%20id%2C%20name%2C%20title%2C%20product_type&fq=product_type%3ANotebook&q.op=OR&q=attr_n_internal_memory%3A%5B*%20TO%20*%5D&rows=100


```
curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/querqy/rewriter/number_unit?action=save -H 'Content-Type: application/json' -d'
{
  "class": "querqy.solr.rewriter.numberunit.NumberUnitRewriterFactory",
  "config": {
       "config":  "{\"numberUnitDefinitions\": [{\"units\": [ { \"term\": \"inch\" } ],\"fields\": [ { \"fieldName\": \"screen_size\" } ]}]}"
  }
}
'
```


{\r\n   \"numberUnitDefinitions\": [\r\n      {\r\n         \"units\": [ { \"term\": \"inch\" } ],\r\n         \"fields\": [ { \"fieldName\": \"screen_size\" } ]\r\n      }\r\n   ]\r\n}



{
   "numberUnitDefinitions": [
      {
         "units": [ { "term": "inch" } ],
         "fields": [ { "fieldName": "screen_size" } ]
      }
   ]
}




{"numberUnitDefinitions": [{"units": [ { "term": "inch" } ],"fields": [ { "fieldName": "screen_size" } ]}]}

{\"numberUnitDefinitions\": [{\"units\": [ { \"term\": \"inch\" } ],\"fields\": [ { \"fieldName\": \"screen_size\" } ]}]}
