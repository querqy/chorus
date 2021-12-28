# Eighth Kata: Find all the Rules for dealing with Zero Results Found!

In this Kata, we're going to learn how to start organizing your queries using the tagging UI in SMUI to let you
label what the various rules are for.  We're going to start out with the simplest use case, tagging all the rules
that are meant for preventing the dreaded Zero Results Found page!

A somewhat fanciful example of a query that returns zero results on the Chorus Electronics webshop is the query
_purple laptop_ assuming you picked the `Must Match All` algorithm on the webshop.   Go ahead and search:

http://localhost:4000/?view=gallery&search_field=mustmatchall_algo&q=purple+laptop

And you see that we get the Zero Results Found page, and worse yet, the Did You Mean Suggestion that is
proposed is the query _purpose_, which makes no sense at all in the context of ecommerce searching!   So
lets do some active search management, and remove the term _purple_.

![Tagging Your Queries](008_tagging_your_queries.png)
