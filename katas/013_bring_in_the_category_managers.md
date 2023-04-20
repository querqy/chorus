# Thirteenth Kata: Bring in the Category Managers

<i><a href="PLACEHOLDER" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

Good news!  Pete has been talking to the various Category Managers responsible for specific areas of the Chorus Electronics website about how to improve the raw relevancy of the search results.  Based on the great results they have seen with doing some basic tuning, _see Fourth Kata: [How to Gather Human Judgements](katas/004_gathering_human_judgements.md)_, they want to start rolling out a proper Human Rating Program.  Meanwhile, Pete has been reading up about new ideas in measuring search, specifically some of the ideas about evaluating search results on the axis of Exact, Same, Relevant, and Irrelevant.  Learn more about "ECSI" rating system with some examples at https://www.aicrowd.com/challenges/esci-challenge-for-improving-product-search.

Chorus Electronics just upgraded to Quepid 7, which introduces a proper interface for subject matter experts and other non technical people to provide ratings (also known as judgements) on the relevancy of a specific product to a search query.  

This Kata is going to walk you through how to stand up your first set of Human Ratings, gathered from multiple judges for each query/doc pair.  We'll touch base on crafting the *Information Need* for each query, and then we'll do a comparison of before and after.

We start by creating our first Team to organize ourselves and the set of Category Managers who will be judging documents.   So let's create a team called "CoRise Search for Product Managers".

We want to have a custom Scorer that uses the ECSI labels instead of the standard ones.  Go to Scorers and find the communal scorer *NDCG@10*.   Click the Clone icon and make a copy.  Call it `ESCI NDCG@10`, and change the labels:

Perfect --> "Exact"
Good --> "Substitute"
Fair --> "Complement"
Poor --> "Irrelevant"

Now, we need to make sure that our "CoRise Search for Product Managers" team can use this new scorer, so make sure to share it from the team.

Okay, now we're ready to go ahead and make a Case for our new queries.   In this Kata we are pointing at the online Chorus setup.   DO WE NEED THIS WHOLE SECTION OR ARE WE SET UP?????

http://chorus.dev.o19s.com:8983/solr/ecommerce/select

id:id, title:title, thumb:img_500x500, name, brand, product_type

&useParams=visible_products

Now, let's add some queries.....

notebook

I am looking for a laptop style computer.   

Projector screen

I am looking for a screen for my project.  I'm thinking about an indoor one, though an outdoor projector screen would be valid.   

&useParams=visible_products,


1. Rating Party!!!!   
    --> Ask class members to join and rate.

2. Okay, let's make it better.   Add a Rule.

querqy_algo

3. Let's add Vectors.

querqy_match_by_txt_emb



visible_products,querqy_algo,querqy_match_by_txt_emb


Now, let's do a comparisoin.

case:
6784

SNapshots:
2462

2463
