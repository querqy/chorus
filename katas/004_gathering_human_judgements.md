# Fourth Kata: How to Gather Human Judgements

<i><a href="https://opensourceconnections.com/blog/2020/12/18/pete-finds-out-how-to-rate-search-results/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

We've done basic Searchandizing by fixing `notebook` and `laptop` queries, however we're realizing that as we make changes to our core algorithm that we are risking getting to a point where we make changes that have unintended side effects.  The dreaded [Whac-A-Mole](https://en.wikipedia.org/wiki/Whac-A-Mole) game.  We also are realizing that we need to extract from the heads of our team a definition of what good search looks like.  Ideally we would use our customers, but in place of actual customers, we'll work with our customer support team to build out some __judgements__, to function as our test data set for measure relevancy.  

You'll recall that in [Kata 001: Optimize a Query](katas/001_optimize_a_query.md) we actually did set up a case with the `laptop` and `notebook` queries.  However, lets now do slightly more comprehensive set of ratings.   We have [sourced a list of 125 queries](https://docs.google.com/spreadsheets/d/1y8ZS53CdHtTcSVPVTqnysQOGRtd7uRKvmKlj3RztEsA/edit?usp=sharing) that represent a broad set of queries on Chorus Electronics.  (In the real world we would source them from query logs!)

We'll use this subset of the full query set as a starting point:

* `bluetooth speaker`
* `surround sound speakers`
* `phone case`
* `garmin`
* `gps watch`
* `flat screen tv`
* `computer`
* `laptop bag`
* `gaming mouse`
* `gaming keyboard`

Go ahead and create a new case by opening up Quepid and choosing from the `Relevancy Cases` dropdown the `Create a Case` option.  Go through the wizard, setting up the case similar to how we did it before, but DON'T put any queries in:

* Url: http://localhost:8983/solr/ecommerce/select
* Title Field: `title`
* ID Field: `id`
* Additional Display Fields: `thumb:img_500x500, name, brand, product_type`

Once the Case shows up, go ahead and cut'n'paste the above queries and paste them in the `Add a query to this case` text bar, and each return delimited query should show up as a query.  This is a secret Easter Egg in Quepid ;-).

Now, we want to go through and think about what the Information Need is for each query.   I like to list the Information Need at the top of the notes for each Query, to remind myself (and others!) what we thought the end user was looking for.

For example, the query `bluetooth speaker` is a simple:

> Information Need: I want portable speakers that connect via bluetooth to a device.

Go through each of the ten queries and come up with the information need.  Yes, this is dull, it's the "eat your vegetables" part of Relevancy Tuning.   Do it as a group activity to make it easier!   To make your life easier, I've [done it for the above queries](https://docs.google.com/spreadsheets/d/1y8ZS53CdHtTcSVPVTqnysQOGRtd7uRKvmKlj3RztEsA/edit#gid=648474003).

Now go ahead and start rating!   My colleague Max wrote up a great explanation for the 0 to 3 scale we use in Ecommerce judgements, illustrated using the Chorus website: https://github.com/o19s/quepid/wiki/Judgement-Rating-Best-Practices

Starting with the first query `bluetooth speaker`, the first three products returned, keeping in mind the Information Need, are clearly great results.  Yes, those are all speakers that connect via bluetooth to a device, so I rate them all a 3.

However, then we start getting other products that match either the token `bluetooth` or `speaker`, and are quite clearly NOT meeting the Information Need.   In fact, they are so clearly bad results that they make me *Mad! - Stupid Chorus website, those aren't what I want!*, so I'm giving them a 0 rating.

We then proceed down through the rest of the queries, giving them ratings.    One issue with our base algorithm is that we often return `accessories` for a product, not the product itself.  So most of our results need a low rating, with only a few needing a high rating.  To make rating faster, we mark all the results with a rating that the majority deserve, and then go back and fix up the few that need a different rating.

At the end of this process, we have our, in machine learning parlance, labeled training data set to help us run experiments to improve search.
