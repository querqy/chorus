# First Kata: Lets Optimize a Query

In this first Kata, we'lre going to take two queries that we know are bad, and see if we can improve them via Active Search Management.   How do we know that the queries _notebook_ and _laptop_ are bad?  Easy, just take a look at them in our _Chorus Electronics_ store.

Visit the store at http://localhost:4000/ and make sure the drop down has _Default Algo_ next to the search bar.   Now do a search for _notebook_, and notice that while the products are all vaguely related to notebooks, none of them are actual notebook computers.   We believe that our users, when they type in _notebook_, are looking for notebook computers, or possibly a paper notebook (which we don't carry as we are a electronics store), not accessories.

Let's see if _laptop_ is any better.  Nope, similarly bad results.  

So what can we do?   Well, first off, just by looking at the search results, we have a intuitive understanding of the problem, but we don't have a good way of measuring the problem.   How bad are our search results for these two queries?  Ideally we would have a numerical (quantitative) value to measure the problem.

Enter Quepid.  Quepid provides two capabilities.  The first is an ability to easily assess the quality of search results through a web interface.  This is perfect for working with a Business Owner or other non technical stakeholders to talk about why search is bad, and gather input on the results to start defining what good search results are for our queries.

The second capability is a safe playground for playing with relevancy tuning parameters, though we won't be focusing on that in this Kata.

Open up Quepid at http://localhost:3000.   Since you have already gone through the Movie Demo setup, we'll need to set up a new case!

Go ahead and start a new case by clicking _Relevancy Cases_ drop down and choosing _Create a Case_.  

Let's call the case _Notebook Computers_.   Then, instead of the default Solr instance, let's go ahead and use our Chorus Electronics index using this URL:

`http://localhost:8983/solr/ecommerce/select`

Click the _ping it_ link to confirm we can access the ecommerce index.

On the _How Should We Display Your Results?_ screen we can customize what information we want to show our Business Owner:  

Title Field: `title`
ID Field: `id`
Additional Display Fields: `thumb:img_500x500, name, supplier, attr_t_product_type`

We want to show our Business Owner enough information about our products so they can understand the context of our search, but not so much they are overwhelmed!

On the next screen lets go ahead and add our problem queries _notebook_ and _laptop_.

Complete the wizard, and now you are on the main Quepid screen.  

Alert!  Sometimes in Quepid when you complete the add case wizard there is a odd race condition and the _Updating Queries_ message stays on the screen instead of going way.  Just reload the page ;-).    

Now, I like to have two browser windows side by side, the _Chorus Electronics_ store open on the left, and Quepid on the right.  You should see the same products listed in both.

Since we are going to pretend we have a Business Owner rating our individual results, we want to have a more sophisticated grading scale than the default one, of "Yes" or "No".  Click _Select Scorer_ and choose the nDCG@5 one from the list.  

nDCG is a commonly used scorer that attempts to measure how good your results are against a ideal set of results, and it penalizes bad search results at the top of the list more than bad results at the end of the list.   

Our scorer is based on a 0 to 4 scale, from 0 being irrelevant, i.e the result "makes the user mad to see", to 4, an absolutely unequivocally perfect result.

Most ratings end up in the 1 for poor or irrelevant and 3 for good or relevant rating.

Our nDCG@5 scorer is setup to only look at the first five results on the page, so think about if you are doing Mobile optimization and your users only have a small amount of screen real estate.   We could do of course do @10 or @20 if we wanted to measure more deeply.

We'll go more deeply into scorers in another Kata.  To save some time, we've already done some rating for you.  

Click the _Import Ratings_ from the toolbar and you'll be in the import modal.

Pick the ratings file that we already created for you from `./katas/Chorus_Electronics_basic.csv`.  You'll see a preview of the CSV file.  Click _Import_ and Quepid will load up these ratings and rerun your queries.  Notice the frog icon went away, that is telling you you don't have any query results that need assessment from the business ;-)

So here is the good/bad news.  Yes our search results are terrible, with a score of 0.14 (on a scale of 0 to 1).  However now we have a numerical value of our search results, and can now think about fixing them!

So now let's think about how we might actually improve them?  There are a lot of ways we could skin this cat, however for ecommerce use cases, one really powerful option is the Querqy query rewriting library for Solr and Elasticsearch.  We won't go into the details of how Querqy works with Solr in this Kata.

To make it easier for the Search Product Manager to do _Searchandizing_, we will use the Search Management UI, or SMUI.  Open up http://localhost:9000 and you will be in the management screen for the _Ecommerce Demo_.

Arrange your screens so the _Chorus Electonics_ store and SMUI are both visible.  Because we are working with the Querqy library, in the _Chorus Electronics_ store, make sure to change form the _Default Algo_ in the dropdown next to the search bar to the _Querqy Algo_.  Do a search for notebook, and while the initial product images may look good to you, remember, they aren't images of notebooks, they are notebook *accessories* that we are getting back!   While we are at it, let's also check _laptop_ as well.

Let's start working on the query _notebook_ by typing it in on the left in SMUI under _Search or Create Search Rules_ text box.  Click _New_ and you get an empty rules set.  

Lets start with filtering _notebook_ to just those products.  Add a new search rule and pick _UP/DOWN rule_.  We'll pick a boost of _UP(++++)_, so pretty heavy boost, and then put in _attr_t_product_type_ as the _Solr Field_, and the _Rule Term_ should be _notebook_.   This will boost products tagged with the notebook category up in the search results.

Go ahead and click _Save search rules for input_ and then let's push our change to Solr by clicking the _Push Config to Solr_.

Go ahead and do a new query in the store, notice the improvements in the quality for _notebook_?  However we're seeing some _cable locks_ and _screen protectors_ showing up.   So let's go ahead and add some rules, and take care of _notebook_ while we are at it:

![Downboosting bad results and setting up synonym](./katas/smui_setup.png)

You can save and push the config as you add rules and then look at the store to see the changes.  Play with the rules!

Now that we have a qualitative sense that we've improved our results using Querqy, lets go ahead and see if we can make this a quantifiable measure of improvement.  Lets see if we can give a number to our stakeholder on improving these _notebook_ related queries.

We'll flip back to Quepid to do this.

We need to tell Quepid that we've done some improvement using the `/querqy-select` request handler, instead of the default handler `/select`.  For this, we need our _Tune Relevance_ pane.  Click the _Tune Relevance_ link and you will be in the _Query Sandbox_.   Append to the end of the existing query template `q=#$query##` the command to tell Solr to use the new request handler: `&qt=/querqy-select`.   Then click the _Rerun My Searches!_ button.

Notice that our results have now turned green across the board from red?  Our graph has also improved from our dismal measurement of 0 to the best possible result of 1!

There is a lot to unpack in here that is beyond the scope of this kata.  However bear with me.

So now we feel like this is good results.  However, while we've just tuned these notebook examples, what has the impact of the Querqy rule changes been on potentially other queries?  Quepid is great for up to 60 or so queries per case, but it doesn't handle 100's or 1000's of queries well.  Plus, we only get one search metric, in our case NDCG at a time. What if I want to calculate all the search metrics.  For that, enter RRE.

RRE uses it's own format of ratings, so in Quepid, click the _Export Case_ option in the toolbar.  This will pop up a modal box, and choose the _Rated Ranking Evaluator_ option.  Then click _Export_ and save this file on your desktop.  

You then need to put this ratings into RRE.  First move any ratings file in `./rre/src/etc/ratings/` out of that directory, leaving them in `./rre` is fine.  Then take your freshly exported `Notebook_Computers_rre.json` file and put it in the ratings directory.  

Now, lets look at the RRE setup.  Open up the `Notebook_Computers_rre.json` file and change the index property from `Notebook Computers` to `ecommerce` to match the name of our Solr index and save that change.

We want to regression test our pre Querqy algorithm and our post Querqy algorithm.  So look at the template files in `./rre/src/etc/templates`.  As you can see v1.0 is just the simplistic query.   However v1.1 is using the Querqy enabled request handler.  This is going to let us measure the two against each other.

While in this kata we are only running the same set of queries as in Quepid, in real life you would be regression testing those two queries against 100's of other rated queries as well.

So let's go run our evaluation!  We're back on the command line:

> docker-compose run rre mvn rre:evaluate

Look for a message about `completed all 2 evaluations` to know that it's running properly.

And once that completes, lets go ahead and publish the reports:

> docker-compose run rre mvn rre-report:report

You have two ways of looking at the results of RRE running.  There is an Excel spreadsheet you can look at, or you can use the online Dashboard available at http://localhost:7979.

Going into what all the metrics that RRE provides, and this is just a small sample set, is beyond this.   Suffice to say, if you look at the NDCG@4 and NDCG@10, you will see that we had a big jump from the terrible results of v1.0 to the amazing results in v1.1!

That all folks!  You've successfully taken two bad queries from the store, assessed them to put a numerical value on the quality of the search, and then improved them using some rules to rewrite the query.  You then remeasured them, saw the quantitative improvement, and then ran a simulated regression test of those queries (and all your other ones in the real world), and have meaningfully improved search quality, which drives more revenue!
