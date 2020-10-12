# Second Kata: How to Sell Search Keywords

Good news!  Our intrepid brand management team for Chorus Electronics has just signed a deal with Epson where every time a customer searches the webshop for the keyword _projector_ and picks an Epson branded projector, we get a bonus fee from Epson.

In this Kata we'll actually walk through the steps to implement this new requirement in our search algorithm.

First off, we need to understand exactly what we mean by selling a keyword.  In our case, a keyword is a very specific search query.  A search for _projector_ matches our criteria for keywords that boost results that favour Epson.   However, similar searches like _projector lamp_ or _projector screen_ should still behave the way they always have.  

We'll want to start by laying our web browser out with the webshop on the left and SMUI on the right.  We're using our Querqy algorithm, so pick it from the dropdown and do what a customer would do, search for a _projector_.

Now enter the keyword `"projector"` into SMUI, notice we are wrapping it with quotes, so we don't match other variations of the query.


Now, there are two ways to mess with this query:  lets first try a BOOST, and see what we see, and then let's try a FILTER.


For the boost we pick a UP/DOWN rule, and go with a very strong boost of UP(++++).  We want to be pretty targeted, so we pick the `brand` field, which is where our brand information lives.

Now look at the results, as you can see that we've pushed the Epson products up to the top, but we still have other product listed.   This is probably the best behavior, balancing the interests of the seller, Epson, to be featured for the _projector_ keyword, while still letting the buyer see products from other brands.

What if Epson had signed an *exclusive* deal for the _projector_ keyword?  In that case for users who are searching for projectors, we're only going to show you Epson branded products.  Now, we could delete all the other brands out of our webshop, but that is pretty cumbersome ;-).   Instead, lets play with the FILTER rule to deal with this use case.

Back into SMUI, and let's remove our old BOOST and add a new FILTER search rule.  Again, as before, lets filter to just the `brand` field of Epson.

Uncheck the first rule, so it's no longer active (isn't that handy?) and then publish the results.

Look at that, our results are now just Epson branded products.   

So some other thoughts:

Properly we should only be showing the single Epson EMP-830 projector in our results first, not the other products.  We could be solving that through maybe boosting a bit on the most viewed items, on the intuition that parts for projectors are viewed much less than projectors themselves.  We could also use some NLP and other techniques to better classify our data, and then filter on that.  We have a `product_type` field, but it's unpopulated for many of our items, like these.



------------


Now, look at the results, this is a very "defensive" change.   There is still some relevant HP projectors here in the first 10 results.  

Now, if we want to be more "offensive" boosting, then we can go with a UP+++++.  Notice that the Epson EMP-830 moved up a rank.  

Now, we see the issue that we are pushing all items that are related to Projector, like screens etc.
Show the previous searches in here.

So, there is an alternative option that is common, which instead of selling all the searches related to _projector_, instead we are selling a specific keyword.   Epson may not care about being boosted for screens or lamps, but for the actual hardware device, they are very interested in it, and will pay a premioujs.  In that case, we are selling them the keyword *"projector"*, which isn't also influencing your _projector screen_ or _projector lamp_ qwueries.

In this case, we go into SMUI, and put in `"projector"`


Third Kata.

Boosting on price.  You are putting a native solr query in SMUI.
