# Ninth Kata: Tagging Your Queries.  Find all the Rules for dealing with Zero Results Found!

In this Kata, we're going to learn how to start organizing your queries using the tagging UI in SMUI to let you
label what the various rules are for.  We're going to start out with the simplest use case, tagging all the rules
that are meant for preventing the dreaded Zero Results Found page!

A somewhat fanciful example of a query that returns zero results on the Chorus Electronics webshop is the query
`purple laptop` assuming you picked the `Must Match All` algorithm on the webshop.   Go ahead and search:

http://localhost:4000/?view=gallery&search_field=mustmatchall_algo&q=purple+laptop

And you see that we get the Zero Results Found page, and worse yet, the Did You Mean Suggestion that is
proposed is the query `purpose`, which makes no sense at all in the context of ecommerce searching!   So
let's do some active search management, and remove the term `purple` from the query, using the `DELETE` rule.

We want to track all the rules related to fixing Zero Results Found issues, so then we use our tags.  From the tags
dropdown you can see the first tag is labeled `zero results`, so go ahead and check it.   This then lets you see
the tag as a pill icon in the left hand area in the list of queries.  

![Tagging Your Queries](images/009_tagging_your_queries.png)

You are probably already thinking _wait, am I going to create a rule like this for every colour?_, and thinking that is an impossible task.   The wonderful thing about active search management is that it lets us start building a list of all the queries for `laptop` that have colour as an attribute.   Tagging queries like `purple laptop` starts creating a dataset that can be used for testing potentially automated solutions.   For example, `silver laptop` is a valid attribute for filtering down a set of laptops, whereas `purple` isn't a useful attribute for filtering.   Once you have a list of queries tagged with `zero results` then you can use that to A/B test a non active search management approach!
