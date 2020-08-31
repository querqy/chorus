
[ ] Check on if Querqy works with SolrCloud.
[ ] Fix the volumne loading of rules.txt.

# Setup

To make sure that the `cat` command is running on the node with the file, you need to control
where you run the command!
https://lucene.apache.org/solr/guide/8_4/collection-management.html#create-parameters

```
#docker exec solr1 solr create_collection -c historical_queries -p 8983 -shards 1
curl  --user solr:SolrRocks -X GET "http://localhost:8983/solr/admin/collections?action=CREATE&name=historical_queries3&numShards=1&replicationFactor=1&createNodeSet=192.168.96.5:8983_solr"


docker cp ./raw_data/kaggle_queries.tsv solr1:/var/solr/data/userfiles/kaggle_queries.tsv

```

```
jq -c '.[]' icecat-products-150k-20200607.json > icecat-products-150k-20200607.jsonl
```

Until we fix the `date_released` format just remove it:
```
jq -c '.[] | del(.date_released)' icecat-products-150k-20200607.json > icecat-products-150k-20200607.jsonl
```

```
docker cp icecat-products-150k-20200607.jsonl solr1:/var/solr/data/userfiles/icecat-products-150k-20200607.jsonl
```

# Register the expression.

```
curl -X POST -H 'Content-type:application/json'  -d '{
  "add-expressible": {
    "name": "parseJSONL",
    "class": "com.o19s.solr.streaming.JSONLStream"
  }
}' http://localhost:8983/solr/ecommerce/config
```

Confirm it's there via:

```
curl 'http://localhost:8983/solr/ecommerce/stream?action=PLUGINS' | grep JSONL
```

```
curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=
parseJSONL(
  cat('icecat-products-150k-20200607.jsonl',  maxLines=500)
)
'
```
If you get back `EXCEPTION": "file/directory to stream doesn't exist: icecat-products-150k-20200607.jsonl",`, then docker cp it to `solr2` and `solr3`!

# Load the data

Run this on `ecommerce` for some reason!

```
cat('icecat-products-150k-20200607.jsonl',  maxLines=10)
```

```
select(
  parseJSONL(
    cat('icecat-products-150k-20200607.jsonl', maxLines=10)
  )
)
```

```
commit(ecommerce,
  update(ecommerce,
    parseJSONL(
      cat('icecat-products-150k-20200607.jsonl', maxLines=10)
    )
  )
)
```

Lets time it!
```
time curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=
commit(ecommerce,
  update(ecommerce,
    parseJSONL(
      cat('icecat-products-150k-20200607.jsonl')
    )
  )
)
'
```

Takes 3:13.82, 2:47.10,  2:43.27, 2:53.70

Compare to tar:
```
time tar xzf icecat-products-150k-20200607.tar.gz --to-stdout | curl 'http://localhost:8983/solr/ecommerce/update?processor=formatDateUpdateProcessor&commit=true' --data-binary @- -H 'Content-type:application/json'
```

Takes 3:06.00

what about straight up jsonl post?
```
time curl -X POST -d @icecat-products-150k-20200607.jsonl -H "Content-Type: application/json" "http://localhost:8983/solr/ecommerce/update?commit=true"
```

Takes 3:05.07, 2:39.16

Can we make it faster?

> docker exec solr1 solr create_collection -c workers -p 8983 -shards 3


```
time curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=

parallel(worker
  commit(ecommerce,
    update(ecommerce,
      parseJSONL(
        cat('icecat-products-150k-20200607.jsonl')
      )
  ),
  workers="3",
  sort="id desc"
)
'
time curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=

parallel(workers,
  update(ecommerce,
    parseJSONL(
      cat('icecat-products-150k-20200607.jsonl')
    )
  ),
  workers="3",
  sort="id desc"
)
'

time curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=

plist(workers,
  update(ecommerce,
    parseJSONL(
      cat('icecat-products-150k-20200607.jsonl')
    )
  ),
  workers="3",
  sort="id desc"
)
```

Okay, this seems to be the fastest!  Couldn't get parallel to do anything ;-(
```
time curl http://localhost:8983/solr/ecommerce/stream --data-urlencode 'expr=
commit(ecommerce,
  update(ecommerce,
    batchSize="1000",
    parseJSONL(
      cat('icecat-products-150k-20200607.jsonl')
    )
  )
)
'

```

Okay, lets look at our source data and count queries.

```

```

```
cat('kaggle_queries.csv',  maxLines=10)
```

```
commit(historical_queries,
  update(historical_queries,
    parseTSV(
      cat('kaggle_queries.tsv', )
    )
  )
)
```
