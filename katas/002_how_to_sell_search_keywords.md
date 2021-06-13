# Second Kata: How to Sell Search Keywords and Terms

<i><a href="https://opensourceconnections.com/blog/2020/10/19/pete-learns-about-selling-search-keywords-with-chorus/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

Good news! Our intrepid supplier management team for Chorus Electronics, led by Pete’s colleague Shanice, has just signed a deal with Epson where every time a customer searches the web shop for the keyword _projector_ and picks an Epson brand projector, Chorus Electronics gets a bonus fee from Epson. However, Pete wants to be sure that whatever he does to please the supplier doesn’t break other similar search queries.

Shanice is also discussing an exclusive deal with Epson, where Chorus would show only their projectors – how can Pete make this happen?

In this Kata we'll actually walk through the steps to implement this new requirement in our search algorithm.

First off, we need to understand exactly what we mean by selling a keyword.  In our case, a keyword is a very specific search query.  A search for _projector_ matches our criteria for keywords that boost results that favour Epson.   However, similar searches like _projector lamp_ or _projector screen_ should still behave the way they always have.  

We'll want to start by laying our web browser out with the web shop on the left and SMUI on the right.  We're using our Querqy algorithm, so pick it from the dropdown and do what a customer would do, search for a _projector_.

Notice we are getting back some HP branded projectors, and the first Epson product is a "Epson Lamp" for a project.  Not very good results!

Now enter the keyword `"projector"` into SMUI; notice we are wrapping it with quotes, so we don't match other variations of the query.

Lets use what we learned in the Kata 001 in dealing with accessories, and add a UP+++ on the `product_type` field for `projector`, which boosts all of our projector types of _Desktop Projector_, _Portable Projector_, and _Ceiling Mounted Projector_.  Good, now we are ready to continue.


Now, there are two ways to mess with this query:  lets first try a BOOST, and see what we see, and then let's try a FILTER.


For the boost we pick a UP/DOWN rule, and go with a very strong boost of UP(++++).  We want to be pretty targeted, so we pick the `brand` field, which is where our brand information lives.

Now look at the results, as you can see that we've pushed the Epson products up to the top, but we still have other product listed.   This is probably the best behavior, balancing the interests of the seller, Epson, to be featured for the _projector_ keyword, while still letting the buyer see products from other brands.

What if Epson had signed an *exclusive* deal for the _projector_ keyword?  In that case for users who are searching for projectors, we're only going to show you Epson branded products.  Now, we could delete all the other brands out of our webshop, but that is pretty cumbersome ;-).   Instead, lets play with the FILTER rule to deal with this use case.

Back into SMUI, and let's remove our old BOOST and add a new FILTER search rule.  Again, as before, lets filter to just the `brand` field of Epson.

Uncheck the first rule, so it's no longer active (isn't that handy?) and then publish the results.

Look at that, our results are now just Epson branded products.   

So, there is an alternative option that is common, which instead of selling the keyword _projector_, instead we are selling the term _projector_, as in _projector screen_ or _projector lamp_, and should all be boosting Epson products.

In this case, lets go back into SMUI, and this time, instead of using `"projector"`, lets update it to just `projector`, but keep the rest of our rules.  Save and rerun it.
