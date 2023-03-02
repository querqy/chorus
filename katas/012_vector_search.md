# Twelfth Kata: Vector Search

## This kata is still a WIP.

## Examining quickstart.sh to see how vector search is setup in Chorus.

Let's take a look at the `quickstart.sh` script, and look for logic that gets run when the flag `vector_search` has been set to `true`.  If you have already run `quickstart.sh` without any additional arguments, you are going to want to run it again using `quickstart.sh -vector`, so that the flag `vector_search` gets set to `true`.  Doing this will make sure that the setup for vector search is run as Chorus starts up.

Here, we see that the embeddings service is added to the list of services:

```bash
if $vector_search; then
  services="${services} embeddings"
fi
```

Another block of the script runs `./solr/index-vectors.sh`.

```bash
if $vector_search; then
  # Populating product data for vector search
  log_major "Populating products for vector search, please give it a few minutes!"
  ./solr/index-vectors.sh
```

That script, seen below, loads 4 product vector json files from s3 and post them to Solr using `curl`:
```bash
#!/bin/bash

DATA_DIR="./solr/data"

if [ ! -f ./solr/data/products-vectors-1.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-1.json.${RESET}"
  curl --progress-bar -o ./solr/data/products-vectors-1.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-vectors-2023-02-08/products-vectors-1.json
fi
if [ ! -f ./solr/data/products-vectors-2.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-2.json.${RESET}"
  curl --progress-bar -o ./solr/data/products-vectors-2.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-vectors-2023-02-08/products-vectors-2.json
fi
if [ ! -f ./solr/data/products-vectors-3.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-3.json.${RESET}"
  curl --progress-bar -o ./solr/data/products-vectors-3.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-vectors-2023-02-08/products-vectors-3.json
fi
if [ ! -f ./solr/data/products-vectors-4.json ]; then
  echo -e "${MAJOR}Downloading the products-vectors-4.json.${RESET}"
  curl --progress-bar -o ./solr/data/products-vectors-4.json -k https://o19s-public-datasets.s3.amazonaws.com/chorus/product-vectors-2023-02-08/products-vectors-4.json
fi

cd $DATA_DIR
for f in products-vectors*.json;
  do
    echo "Populating products from ${f}, please give it a few minutes!"
    curl --user solr:SolrRocks 'http://localhost:8983/solr/ecommerce/update?commit=true' --data-binary @"$f" -H 'Content-type:application/json ';
    sleep 5
   done;
```

Back to `quickstart.sh`, we see this block of script prepares the embeddings rewriters, one curl command posts to Solr the rewriter factory for `minilm``, and the other one posts the one for `clip`:
```bash
if $vector_search; then
  # Embedding service for vector search
  log_major "Preparing embeddings rewriter."

  curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/querqy/rewriter/embtxt?action=save -H 'Content-type:application/json'  -d '{
    "class": "querqy.solr.embeddings.SolrEmbeddingsRewriterFactory",
           "config": {
               "model" : {
                 "class": "querqy.embeddings.ChorusEmbeddingModel",
                 "url": "http://embeddings:8000/minilm/text/",
                 "normalize": false,
                 "cache" : "embeddings"
               }
           }
  }'

  curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/querqy/rewriter/embimg?action=save -H 'Content-type:application/json'  -d '{
    "class": "querqy.solr.embeddings.SolrEmbeddingsRewriterFactory",
           "config": {
               "model" : {
                 "class": "querqy.embeddings.ChorusEmbeddingModel",
                 "url": "http://embeddings:8000/clip/text/",
                 "normalize": false,
                 "cache" : "embeddings"
               }
           }
  }'
fi
```

The last piece of script to take a look at is the following one, which defines vector enabled relevancy algorithms using ParamSets. There are 4 of them, one for boost by image (img), one for match by image, one for boost by text (txt) and one for match by text:

```bash
if $vector_search; then
  log_minor "Defining Vector enabled relevancy algorithms using ParamSets."

  curl --user solr:SolrRocks -X POST http://localhost:8983/solr/ecommerce/config/params -H 'Content-type:application/json'  -d '{
    "set": {
      "querqy_boost_by_img_emb":{
        "defType":"querqy",
        "querqy.rewriters":"embimg",
        "querqy.embimg.topK": 100,
        "querqy.embimg.mode": "BOOST",
        "querqy.embimg.boost": 10000,
        "querqy.embimg.f": "product_image_vector",
        "qf": "id name title product_type short_description ean search_attributes",
        "querqy.infoLogging":"on",
        "mm" : "100%"
      }
    },
    "set": {
      "querqy_match_by_img_emb":{
        "defType":"querqy",
        "querqy.rewriters":"embimg",
        "querqy.embimg.topK":100,
        "querqy.embimg.mode": "MAIN_QUERY",
        "querqy.embimg.f": "product_image_vector",
        "qf": "id name title product_type short_description ean search_attributes",
        "querqy.infoLogging":"on",
        "mm" : "100%"

      },
      "querqy_boost_by_txt_emb":{
        "defType":"querqy",
        "querqy.rewriters":"embtxt",
        "querqy.embtxt.topK": 100,
        "querqy.embtxt.mode": "BOOST",
        "querqy.embtxt.boost": 10000,
        "querqy.embtxt.f": "product_vector",
        "qf": "id name title product_type short_description ean search_attributes",
        "querqy.infoLogging":"on",
        "mm" : "100%"
      },
      "querqy_match_by_txt_emb":{
        "defType":"querqy",
        "querqy.rewriters":"embtxt",
        "querqy.embtxt.topK":100,
        "querqy.embtxt.mode": "MAIN_QUERY",
        "querqy.embtxt.f": "product_vector",
        "qf": "id name title product_type short_description ean search_attributes",
        "querqy.infoLogging":"on",
        "mm" : "100%"
      }
    },
  }'
fi
```

## Understanding Vector Search

Let's dive into Vector Search!

What we refer to as "vector search" is also known as "neural search", or "dense vector search", or sometimes "cognitive search", among other names.

In traditional search, sparse vectors are used in bit sets.  A sparse vector contains a list of numbers and a lot of those values are going to equal to zero, and a few non-zero values.  This is typical in traditional search, where there are a lot of bits (thousands) dedicated to whether or not a document does or does not meet some criteria.  A silly and overly simplified example of a sparse vector might look something like the following scenario:

Lamborghini Convertible Aventador S 2023
is a car? is a plate?  is a person?  is a tuna fish sandwich?
1         0            0             0

Kathy Kinney, the currently reigning mighty sound effects lady who works behind the scenes on The Price is Right
is a car? is a plate?  is a person?  is a tuna fish sandwich?
0         0            1             0

A delicious homemade grilled tuna melt sandwich.
is a car? is a plate?  is a person?  is a tuna fish sandwich?
0         0            0             1

A really cool plate from the 80s featuring E.T. on it
is a car? is a plate?  is a person?  is a tuna fish sandwich?
0         1            0             0

If we pack the bits in order, we get:

Lambo: 8
Kathy: 2
Tuna Melt: 1
E.T. plate: 4


Maybe there is a document that is a story about Kathy being chauffered around in a Lamborghini and while she is riding in the passenger seat, she is also eating a delicious tuna melt off of an awesome E.T. plate from 1982, for some unknown reason.  In this case, such a document would be hit the "all things are true" case, and get a 1-1-1-1 which would be 1+2+4+8, or 15.  A different document containing a news story about a surfer dude from Malibu California who doesn't own a car and eats almost exclusively pepperoni pizza, and just broke a record for the Guinness Book of World Records, would be a 0, in this odd sparse vector that we concocted for illustrative purposes only.  As you can see, there are an infinite number of stories that might get all zeroes, in a sense, "striking out" for each and every criteria that we had selected for each of our bits in our vector.

Dense vectors in contrast to sparse vectors, are different, in the sense that all the numbers in the vector are more often "filled in", and not set to be zero. Again in sparse vectors, there are lots of zeroes a lot of the time.  In dense vectors, there are seldom values that are exactly zero. More typically, we use very precise numbers that have a lot of significant digits after the decimal point and may use floating point numbers between negative 1 and positive 1 or between 0 and positive 1, to keep things simple.

Sparse vectors have the advantage that they can be packed into bit sets because each number or "answer" is yes or no and so must be either 0 or 1.  It only takes one bit to store each well, "bit", of information, but you still have to have lots of bits, and each bit has to have a very specific meaning.

In dense vectors, the numbers are not storing "bits" but instead are storing complex coordinates in a multidimensional, imaginary, location in space.

Dense vectors contain almost exclusively non-zero values, which allows packing in a dense of relative information, or the number of bits allocated to the information being stored.  The numbers in the dense vector do not "mean" anything except a location in space that is arranged so that all things that are similar to each other are always piled together nearby in that space.

To use a very silly and overly simplified example of a "dense vector" that contains just one numeric value (so that we can understand it easily), we might store information about the same things in our spare vector example above in a "dense" way as follows:

All the cars go in the range -200 to -100, all the plates are located from -50 to -20, all food objects go in the range 100 to 150 and people are found in the range 2000 to 2100.

Tuna Melt: 125
E.T. Plate: -35
Kathy Kinney: 2050
Lambo: -150

(Note that perhaps we mean "dense" in more than one word sense?)

Maybe they are arranged this way because people can eat food and food goes on plates and plates and cars are inanimate objects but tuna fish sandwiches are made of fish, which were alive once.  You kind have to squint here.  You can sort of ignore strange questions like what a person has in common with a car, for example, that they both can go places.  Just realize that the most important thing is that cars are clumped together into the same area, all the food is clumped together, all the people are clumped and all the plates are similar to each other.  After all, as the Mad Hatter asked: "Why is a raven like a writing desk?"  It is a riddle, and is purposefully nonsensical.  There might be some sly answer if you do some mental gymnastics and look around on the Internet, but you can always find things that have almost nothing to do with some random object that you pick.  That's okay.  Both things still belong somewhere in the universe of things that exist.

Just like a point in space is a degenerate circle, but technically can be still be considered a "circle", this example is a very degenerate case of the "dense vectors" that we are talking about.  In fact, the dense vectors we will be using in practice have a much larger "space" than just the number line.  Instead of one float number along the number line, we will use vectors that contain lists of hundreds of floating point numbers, which is highly multidimensional, mathematically.  When you think about multidimensional space, you might picture something like a "multiverse" that has been imagined in fictional movies.  You can imagine the numbers in the first slot as numbers along a line in Multiverse 1, and the numbers in the second spot as numbers along a totally different number line in Multiverse 2, and so on.  Each specific combination of numbers is a "spot" or a dialed-in selection, and these numbers are set so that if you tweaked just one of the numbers by just a little bit in the vector space, you'll very likely get something that is really pretty much the same thing as your original item.  Another way you might consider it is hundreds of combinations on a magic safe, where a magician secretly puts in the correct item for that combination just before you open the door.   Another way to think of it is just like "telephone numbers"...where you can imagine that because of the way these numbers were dolled out, it is guaranteed that items that have very similar phone numbers to each other also happen to be mathemagically "neighbors" and that means they are also similar to each other in certain ways.  But if you go around tweaking a bunch of numbers in random ways, you will find yourself looking at a very different item, semantically, but it is fairly unpredictable what you'll get, but then if you start from there, and nudge numbers just a little bit again, you will be finding similar items to whatever item you landed on when you "spun the dials".   Essentially, this is the idea.  Things that are similar to each other get packed close together in a semantic areas, in the vector space.

Given that we are dealing with multidimensions, things may be similar to other things in various ways a plush rabbit might be similar to a real rabbit in that they are both "rabbits".  It can also be true that a plush rabbit is similar to a plush teddy bear in that they are both made out of the same material.  The idea of the Velveteen Rabbit might be closer to a real rabbit than a plush rabbit because in the story, the plush rabbit becomes real at the end of the story.  A real rabbit might also be similar to a plush teddy bear, because they are both fuzzy.  Similarities may be in lots of different directions in the different dimensions of the multiverse.  This is how dense vectors work in the semantic vector space.

The main take away is that things that are similar to each other (in some way or other, at least), end up getting number combinations in the vector space that are quite similar to each other, and things that are totally different and "far away" or "dissimilar" (to a chosen item) will have very different number combinations.

It is not necessary to try to "understand" the vector numbers themselves, only that by the virtue of this encoding, we can perform cosine similarity on the vectors, and find similar or dissimilar items, given a starting location.  Taken out of context, there is no information in the numbers themselves, just as a point is hardly makes a true circle, logically speaking.  A point, on its own in a universe of nothing, means nothing.  But in a space, given 2 points you define a line or a line segment, and with 3 points you can define a plane, and with 4 or more points you can define a 3D object.  The important thing to know is that these numbers "mean something" only when we consider the distances to other points in the vector space.

In the case of traditional recommendations, dense vectors may be leveraged to find a list of "recommended" items for a product detail page.

When used in the search context, we are trying to find documents, products, objects, things that match the query text, or give an extra boost to documents that are deemed to be close to your query, mathematically speaking, in terms of distance similarity.  In the case of image vectors, we are trying to match the query text to the images of products (as they were labeled with text), or boost items that have images labeled in ways that are found to be nearby in the vector space to the search query.

It is a useful data structure for representing data that is mostly empty or has a lot of zeros. For example, if you have a vector of length 10,000 and only 10 elements are non-zero, then it is a sparse vector.

All of these zeroes do not add a lot of information, and they take up space.

In dense vector search, the vector is used in a different way, and a 

