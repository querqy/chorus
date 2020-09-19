# Second Kata: Lets

Lets think about two Katas, one that is selling queries and one is selling terms.

query == "projector"
term == projector


Good news!  We (Chorus Electonrics) just signed a deal with Epson to sell the search for _projector_ to feature their products.  So *projector screen*, *projector lamp*, as well as the actual device, a *projector*.

Lets do a search for _projector lamp_ (link) and you see that HP and Sony products come before the Epson products.   

Likewise, a search for _projectors_ returns a mix.






We go into SMUI and add a up/down rule, doing a UP+, we want to be pretty targeted, so we pick the `supplier` field, you might have a brand field isntead.


Now, look at the results, this is a very "defensive" change.   There is still some relevant HP projectors here in the first 10 results.  

Now, if we want to be more "offensive" boosting, then we can go with a UP+++++.  Notice that the Epson EMP-830 moved up a rank.  

Now, we see the issue that we are pushing all items that are related to Projector, like screens etc.
Show the previous searches in here.

So, there is an alternative option that is common, which instead of selling all the searches related to _projector_, instead we are selling a specific keyword.   Epson may not care about being boosted for screens or lamps, but for the actual hardware device, they are very interested in it, and will pay a premioujs.  In that case, we are selling them the keyword *"projector"*, which isn't also influencing your _projector screen_ or _projector lamp_ qwueries.

In this case, we go into SMUI, and put in `"projector"`


Third Kata.

Boosting on price.  You are putting a native solr query in SMUI.
