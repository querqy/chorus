# First Kata: Lets Optimize a Query

<i><a href="https://opensourceconnections.com/blog/2020/08/01/pete-solves-the-e-commerce-search-accessories-problem-with-boosting-synonyms/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

In this first Kata, we're going to take the query 'notebook' that we know is bad, and see if we can improve it using Active Search Management.   How do we know that the results for the query `notebook` is bad?  Easy, just take a look at it in our `Chorus Electronics` store ;-).

Visit the web store at http://localhost:4000/ and make sure the drop down has `Default Algo` next to the search bar selected.   Now do a search for `notebook`, and notice that while the products are all vaguely related to notebooks, none of them are actual notebook computers.   We believe that our users, when they type in `notebook`, are looking for notebook computers, or possibly a paper notebook (which we don't carry as we are a electronics store), not accessories to notebooks.

So what can we do?   Well, first off, just by looking at the search results, we have a intuitive understanding of the problem, but we don't have a good way of measuring the problem. How bad are our search results for these two queries?  Ideally we would have a numerical (quantitative) value to measure the problem.

Enter Quepid.  Quepid provides two capabilities.  The first is an ability to easily assess the quality of search results through a web interface.  This is perfect for working with a Business Owner or other non technical stakeholders to talk about why search is bad, and gather input on the results to start defining what good search results are for our queries.

The second capability is a safe playground for playing with relevancy tuning parameters, though we won't be focusing on that in this Kata.

Open up Quepid at http://localhost:3000.  Go ahead and sign up through the OpenID link.  

Since you have already gone through the `Movie Demo` setup, we'll need to set up a new case!

Go ahead and start a new case by clicking `Relevancy Cases` dropdown and choosing `Create a Case`.  

Let's call the case `Notebook Computers`.   Then, instead of the default Solr instance, let's go ahead and use our Chorus Electronics index using this URL:

`http://localhost:8983/solr/ecommerce/select`

Click the `ping it` link to confirm we can access the ecommerce index.

On the `How Should We Display Your Results?` screen we can customize what information we want to show our Business Owner:  

* Title Field: `title`
* ID Field: `id`
* Additional Display Fields: `thumb:img_500x500, name, brand, product_type`

We want to show our Merchandizer enough information about our products so they can understand the context of our search, but not so much they are overwhelmed!

On the next screen lets go ahead and add our problem queries `notebook` and `laptop`.

Complete the wizard, and now you are on the main Quepid screen.  

Alert!  Sometimes in Quepid when you complete the add case wizard there is a odd race condition and the `Updating Queries` message stays on the screen instead of going way.  Just reload the page ;-).    

Now, I like to have two browser windows side by side, the `Chorus Electronics` store open on the left, and Quepid on the right.  You should see the same products listed in both.

Since we are going to pretend we have a Merchandizer rating our individual results, we want to have a more sophisticated grading scale than the default binary one, of "0 - Irrelevant" or "1 - Relevant".  In Quepid, click `Select Scorer` and choose the nDCG@10 one from the list.  

nDCG is a commonly used scorer that attempts to measure how good your results are against a ideal set of results, and it penalizes bad search results that show up at the top of the list more than bad results that show up at the end of the list.   

Our scorer is a graded scorer, from 0 to 3, from 0 being irrelevant, i.e the result "makes the user mad to see the result", to 3, an absolutely unequivocally perfect result.

Most ratings end up in the 1 for poor or irrelevant and 3 for good or relevant rating.

Our nDCG@10 scorer is setup to only look at the first ten results on the page, so think about if you are doing Mobile optimization and your users only have a small amount of screen real estate.   We could do of course do @20 or @40 if we wanted to measure more deeply.

We'll go more deeply into scorers in another Kata.  To save some time, we've already done some rating for you.  

In Quepid, click `Import` from the toolbar and you'll be in the import modal.

Pick the ratings file that we already created for you from `./katas/Chorus_Electronics_basic.csv`.  You'll see a preview of the CSV file.  Click `Import` and Quepid will load up these ratings and rerun your queries.  Notice the frog icon went away, that is telling you you don't have any query results that need assessment from the business ;-)

So here is the good news/bad news.  Yes our search results are terrible, with a score of 0.14 (on a normalized scale of 0 to 1).  However now we have a numerical value of our search results, and can now think about fixing them!

So now let's think about how we might actually improve them?  There are a lot of ways we could skin this cat, however for ecommerce use cases, one really powerful option is the Querqy query rewriting library for Solr and Elasticsearch.  We won't go into the technical details of how Querqy works with Solr in this Kata.

To make it easier for the Search Product Manager to do `Searchandizing`, we will use the Search Management UI, or SMUI.  Open up http://localhost:9000 and you will be in the management screen for the `Ecommerce Demo`.

Arrange your screens so the `Chorus Electonics` store and SMUI are both visible.  

![Layout out your webstore and tuning tools side by side](images/001_screens_side_by_side.png)

Because we are working with the Querqy library, in the `Chorus Electronics` store, make sure to change form the `Default Algo` in the dropdown next to the search bar to the `Querqy Live`.  Do a search for notebook, and while the initial product images may look good to you, remember, they aren't images of notebooks, they are notebook *accessories* that we are getting back!   While we are at it, let's also check `laptop` as well.

Let's start working on the query `notebook` by typing it in on the left in SMUI under `Search or Create Search Rules` text box.  Click `New` and you get an empty rules set.  

Lets start with filtering `notebook` to just those products.  Add a new search rule and pick `UP/DOWN rule`.  We'll pick a boost of `UP(++++)`, so pretty heavy boost, and then put in `product_type` as the `Solr Field`, and the `Rule Term` should be `notebook`.   This will boost products tagged with the notebook category up in the search results.

Go ahead and click `Save search rules for input` and then let's push our change to Solr by clicking the `Push Config to Solr` and then `Publish to LIVE`.

Go ahead and do a new query in the store, notice the improvements in the quality for `notebook`?  However we're seeing some `cable locks` and `screen protectors` showing up.   So let's go ahead and add some rules, and take care of `notebook` while we are at it:

![Downboosting bad results and setting up synonym](images/001_smui_setup.png)

You can save and push the config as you add rules and then look at the store to see the changes.  Play with the rules!

Now that we have a qualitative sense that we've improved our results using Querqy, lets go ahead and see if we can make this a quantifiable measure of improvement.  Lets see if we can give a number to our stakeholder on improving these `notebook` related queries.

We'll flip back to Quepid to do this.

We need to tell Quepid that we've done some improvement using the `querqy` request handler, instead of the default handler.  For this, we need our `Tune Relevance` pane.  Click the `Tune Relevance` link and you will be in the `Query Sandbox`.   Append to the end of the existing query template `q=#$query##` the command to tell Solr to use the Querqy query parser by specifying the relevant parameter: `&useParams=querqy_algo`.   Then click the `Rerun My Searches!` button.

Notice that our results have now turned green across the board from red?  Our graph has also improved from our dismal measurement of 0 to an almost perfect result of 0.94!

There is a lot to unpack in here that is beyond the scope of this kata.  However bear with me.

So now we feel like this is good results.  However, while we've just tuned these notebook examples, what has the impact of the Querqy rule changes been on potentially other queries?  Quepid is great for up to 60 or so queries per case, but it doesn't handle 100's or 1000's of queries well.  Plus, we only get one search metric, in our case NDCG at a time. What if I want to calculate all the search metrics.  For that, enter RRE.

RRE uses it's own format of ratings, so in Quepid, click the `Export` option in the toolbar.  This will pop up a modal box, and choose the `Rated Ranking Evaluator` option.  Then click `Export` and save this file on your desktop.  

You then need to put this ratings into RRE.  First move any ratings file in `./rre/src/etc/ratings/` out of that directory, leaving them in `./rre` is fine.  Then take your freshly exported `Notebook_Computers_rre.json` file and put it in the `ratings` directory.  

Now, lets look at the RRE setup. We want to regression test our pre Querqy algorithm and our post Querqy algorithm.  So look at the template files in `./rre/src/etc/templates`.  As you can see `v1.0` is just the simplistic query.   However `v1.1` is using the Querqy enabled request handler.  This is going to let us measure the two against each other.

While in this kata we are only running the same set of queries as in Quepid, in real life you would be regression testing those two queries against 100's of other rated queries as well.

So let's go run our evaluation!  We're back on the command line:

```sh
docker-compose run rre mvn rre:evaluate
```

Look for a message about `completed all 2 evaluations` to know that it's running properly.

And once that completes, lets go ahead and publish the reports:

```sh
docker-compose run rre mvn rre-report:report
```

You have two ways of looking at the results of RRE running.  There is an Excel spreadsheet you can look at, or you can use the online Dashboard available at http://localhost:7979.

Going into what all the metrics that RRE provides, and this is just a small sample set, is beyond this.   Suffice to say, if you look at the NDCG@4 and NDCG@10, you will see that we had a big jump from the terrible results of v1.0 to the amazing results in v1.1!

That all folks!  You've successfully taken a bad 'notebook' query, assessed it to put a numerical value on the quality of the search, and then improved it using some rules to rewrite the query.  You then remeasured, saw the quantitative improvement, and then ran a simulated regression test of those queries (and all your other ones in the real world), and have meaningfully improved search quality, which drives more revenue!
