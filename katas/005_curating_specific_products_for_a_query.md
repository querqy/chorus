# Fifth Kata: Some days you just KNOW what the right products are for a query!

In this Kata, we're going to learn how to throw all that fancy algorithmic power away, and just manually specify the products to return for a specific search query.    

> The first time I used this approach was in attempting to improve the results for the query 'milk' on a grocery site.   I don't want milk chocolate, I don't want milk of magnesia, indeed, I don't want almond milk.    I want 2% milk followed by whole milk, followed by soy milk and almond milk.   I tried lots of "smart" things, and eventually gave up and hard coded the results!   - Eric Pugh

Visit the web store at http://localhost:4000/ and make sure the drop down has _Default Algo_ next to the search bar selected.   Now do a search for _projector_, and notice that we're getting a lot of accessories for projectors.   While we have learned how to tune this to return fewer accessories to projectors, sometimes you just want to hardcode the specific projectors to return!

We have three specific projectors that we want to return for this query, and they have the `id`'s 49058, 77190520, 3795453:

![HP vp6110 Digital Projector](http://images.icecat.biz/img/gallery_mediums/49058_7366366110.jpg)
![Philips PPX320](http://images.icecat.biz/img/gallery_mediums/77190520_9591890324.jpg)
![Samsung P410M](http://images.icecat.biz/img/gallery_mediums/img_3795453_medium_1481101429_6334_23568.jpg)

We're going to do some Querqy magic to map the query _projector_ to these three products using the `id` field, however if you have a `sku` field, it could be the same!

Open up http://localhost:9000 and you will be in the management screen for SMUI for the _Ecommerce Demo_.

Create a new query for _projector_ and when the spelling versus rules management popup comes, pick the Rules.

Step 1 is to map the query term _projector_ to our list of products by id.  Create a `SYNONYM` rule which is _directed_, i.e with the `-> (directed)` operator to the first product you want.  From our list of three products above, it would be to `49058`.

Step 2 is to now filter down to just the product we want.   To start with, add a `FILTER` rule and specify the field `id`, and then value should be `49058`.

Go ahead and save and publish it, and then go back to Blacklight and search for _projector_ with Querqy enabled: http://localhost:4000/catalog?utf8=%E2%9C%93&view=gallery&search_field=querqy&q=projector.

You should see the _HP vp6110 Digital Projector_ listed as the only product.   

Great, but we want more!

Back into SMUI, and now, change the `FILTER` rule to be a list of products filtered on the `id` field by changing the value to a space delimited list of id's, wrapped in parenthesis:  `(49058 77190520 3795453)`.   Publish the rule and go check it out!

![SMUI Screenshot](005_smui_screenshot.png)

Just edit that rule to manage which products are filtered on.
