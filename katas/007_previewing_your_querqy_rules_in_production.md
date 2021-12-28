# Seventh Kata: Seven is a lucky number in many cultures, but what if you don't feel lucky with your rules?

In this Kata, we're going to learn how to preview the impact of your Querqy rules for your webshop before your customers see them!

> Many ecommerce teams manage multiple sets of environments, from Production, to Staging, to Development, and code goes forward from Development through Staging to Production, while data moves backwards from Production to the lower environments.   However the rules managed by SMUI could be treated like code, OR, they could be treated like data!

Go ahead and do a search for `case` and then `backpack` using the `Default Algo` on the website at http://localhost:4000.   They both return reasonable results, so maybe it would make sense to make a query for `case` a SYNONYM for `backpack`?   We can test this by creating the synonym in SMUI.  

Deploy this rule to our *Prelive* environment by clicking the `Push Config to Solr` button in the header instead of the normal `Publish to LIVE` button.   

Now, bring up the Chorus Webshop again, and this time pick from the dropdown `Querqy Prelive`.   Now do your search for `backpack` and you'll see a mixture of backpacks and some other case related products.   Swap the dropdown to `Querqy Live` and run the search again to see the difference.   

Now, if you feel like the changes are worthwhile, then click the `Publish to LIVE` and those rules will be made available to everyone (assuming `Querqy Live` is the default algorithm ;-) ). 

This is implemented by having two sets of querqy rules.   Up to now we have only used the `common_rules` and `replace` rewriters.   However, if you go check out the Solr end point for Querqy at http://localhost:8983/solr/ecommerce/querqy/rewriter you will see that we have now added `common_rules_prelive` and `replace_prelive`.

One more note, which is that if you are setting up a Quepid case, you learned in Kata 000 that you need to explicitly use the `defType=querqy`, however to use the prelive version of the rules you will need to explicitly specify them:

```
defType=querqy&querqy.rewriters=replace_prelive,common_rules_prelive,regex_screen_protectors
```

In our Chorus webshop we have an explicit drop down that picks between algorithms that anyone can use. In a real
webshop you would select the prelive versus live query rules either using a magic parameter in the url like `prelive=true` or by having a drop down that only shows up for Merchandizers to control which is picked.
