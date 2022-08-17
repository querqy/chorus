# Tenth Kata: Establishing a Baseline Metric for Relevancy

<i><a href="https://opensourceconnections.com/blog/2020/10/19/pete-estabalishes-a-baseline/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

At this point, you are probably starting to see that the butterfly effect has a very powerful impact on your relevancy tuning efforts.  For those you aren't familiar with the term, the butterfly effect is:

> is the idea that small, seemingly trivial events may ultimately result in something with much larger consequences – in other words, they have non-linear impacts on very complex systems. For instance, when a butterfly flaps its wings in India, that tiny change in air pressure could eventually cause a tornado in Iowa.  https://science.howstuffworks.com/math-concepts/butterfly-effect.htm

Where we see this in our relevancy tuning is that you improve the results for one query, and yet that has unanticipated impacts on many other queries.   Some times the unanticipated impacts are a pleasant surprise, improving many other queries.  More commonly, the optimal solution for one query has some negative impact on other queries.    

To deal with this, to use another analogy; _we need to look at the forest, not the trees_, and we do this by creating a Baseline Relevancy Case in Quepid.

The Baseline Relevancy Case is a set of queries that represents the typical queries we are getting.   You should source them from your query logs to they represent real queries, and it should have queries that come from both your Head and your Long Tail of queries that users are running.  100 queries is enough to get started, though more is always better ;-).

Once you have those queries defined, go ahead and pick your rating scheme.   Some folks like a binary grade of _relevant_ and _irrelevant_, others go with a graded approach.   For more on the graded approach, see https://github.com/o19s/quepid/wiki/Judgement-Rating-Best-Practices.

Now go through and rate your queries.  You may be interested in [Fourth Kata: How to Gather Human Judgements](004_gathering_human_judgements.md) and the Meet Pete blog post [Pete learns how to scale up search result rating](https://opensourceconnections.com/blog/2021/01/25/pete-learns-how-to-scale-up-search-result-rating/).

For the purposes of Chorus, we have a set of queries that are already rated called (Broad_Query_Set_rated.csv)[Broad_Query_Set_rated.csv] that are ready to be imported into Quepid.  

For those who are using the `quickstart.sh` script, we programmatically create the case and load the queries and rating data for you.

Go ahead and create a case in Quepid, called "Chorus Baseline Relevance" with the following settings:

* Name: `Chorus Baseline Relevance`
* Search engine: `solr`
* URL: `http://localhost:8983/solr/ecommerce/select`
* ID:  `id`
* Title: `title`
* Fields: `thumb:img_500x500, name, brand, product_type`
* Queries: skip this step

Pick the scorer `nDCG@10` and tweak the default query to be `q=#\$query##&useParams=visible_products,querqy_algo`.

Now you are ready to import the (Broad_Query_Set_rated.csv)[Broad_Query_Set_rated.csv] file.  Use the Import Blah.


You how have your _Chorus Baseline Relevance_ case ready.   Go ahead and take a snapshot, giving it the current date.  This will be what you compare back against as you solve specific relevancy problems.   Each time you have a candidate algorithem ready to go, bring up this baseline, and compare it against your snapshot.  
