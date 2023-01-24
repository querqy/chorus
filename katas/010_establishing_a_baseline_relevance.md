# Tenth Kata: Establishing a Baseline Metric for Relevancy

<i><a href="https://opensourceconnections.com/blog/2023/01/03/establishing-a-baseline-relevance-metric/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

At this point, you are probably starting to see that the butterfly effect has a very powerful impact on your relevancy tuning efforts.  For those you aren't familiar with the term, the butterfly effect is:

> is the idea that small, seemingly trivial events may ultimately result in something with much larger consequences – in other words, they have non-linear impacts on very complex systems. For instance, when a butterfly flaps its wings in India, that tiny change in air pressure could eventually cause a tornado in Iowa.  https://science.howstuffworks.com/math-concepts/butterfly-effect.htm

We see this effect daily in our relevancy tuning work. You improve the results for one query, and that change has unanticipated impacts on many other queries. Sometimes the unanticipated impacts are a pleasant surprise, improving many other queries. More commonly, it has a negative impact on other queries.

To deal with this, to use another analogy; _we need to look at the forest, not the trees_, and we do this by creating a Baseline Relevancy Case in Quepid.

The Baseline Relevancy Case is a set of queries that represents the typical queries that we are getting from our overall customer base. You should source them from your query logs so they represent real queries, and it should have queries that come from both your Head and your Long Tail of queries that users are running. 100 queries is typically enough to get started, though more is always better ;-).  There is an art form to picking the right sample set, you may be interested in [How to succeed with explicit relevance evaluation using Probability-Proportional-to-Size sampling](https://opensourceconnections.com/blog/2022/10/13/how-to-succeed-with-explicit-relevance-evaluation-using-probability-proportional-to-size-sampling/).

Now go through and rate your queries.  We want to use a graded approach, so see https://github.com/o19s/quepid/wiki/Judgement-Rating-Best-Practices for more details.

You may be interested in [Fourth Kata: How to Gather Human Judgements](004_gathering_human_judgements.md) and the Meet Pete blog post [Pete learns how to scale up search result rating](https://opensourceconnections.com/blog/2021/01/25/pete-learns-how-to-scale-up-search-result-rating/).

For the purposes of making the learning process using Chorus quicker, we have a set of queries that are already rated called [Broad_Query_Set_rated.csv](Broad_Query_Set_rated.csv) that are ready to be imported into Quepid.  

For those who are using the `quickstart.sh` script, we programmatically create the case `Chorus Baseline Relevance` and load the queries and rating data for the `admin@choruselectronics.com` user.

Otherwise, for those not using the `quickstart.sh`, go ahead and create a case in Quepid, called "Chorus Baseline Relevance" with the following settings:

* Name: `Chorus Baseline Relevance`
* Search engine: `solr`
* URL: `http://localhost:8983/solr/ecommerce/select`
* Title: `title`
* ID:  `id`
* Fields: `thumb:img_500x500, name, brand, product_type`
* Queries: _skip this step!_

Pick the scorer `nDCG@10` and tweak the query sandbox to be `q=#$query##&useParams=visible_products,querqy_algo`.  Click `Rerun my Searches` to save your query changes.

Now you are ready to import the [Broad_Query_Set_rated.csv](Broad_Query_Set_rated.csv) file.  Use the Import button and pick the CSV format and import the file.  This will load all the queries and ratings in Quepid, and then run all the queries and rescore everything.

You how have your _Chorus Baseline Relevance_ case established using the nDCG@10 metric. Go ahead and take a snapshot, giving it today's date.  This will be what you compare back against as you solve specific relevancy problems.  Each time you have a candidate algorithm ready to go, bring up this baseline case, and update the algorithm settings for your new candidate setting.  Then, rerun the queries, and compare it against the snapshot you just established.

In a future Kata we'll go into more depth on the lifecycle of running an experiment and coming back and comparing it to the Baseline.
