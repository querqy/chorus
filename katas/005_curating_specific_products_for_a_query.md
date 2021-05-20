# Fifth Kata: Some days you just KNOW what the right products are for a query!

In this Kata, we're going to learn how to throw all that fancy algorithmic power away, and just manually specify the products to return for a specific search query.    

> The first time I used this approach was in attempting to improve the results for the query 'milk' on a grocery site.   I don't want milk chocolate, I don't want milk of magnesia, indeed, I don't want almond milk.    I want 2% milk followed by whole milk, followed by soy milk and almond milk.   I tried lots of "smart" things, and eventually gave up and hard coded the results!   - Eric Pugh

Visit the web store at http://localhost:4000/ and make sure the drop down has _Default Algo_ next to the search bar selected.   Now do a search for _projector_, and notice that we're getting a lot of accessories for projectors.   While we have learned how to tune this to return fewer accessories to projectors, sometimes you just want to hardcode the specific projectors to return!

We have three projectors that we want to return, and they have the _id_'s 49058, 77190520, 3795453.

![HP vp6110 Digital Projector](http://images.icecat.biz/img/gallery_mediums/49058_7366366110.jpg)
![Philips PPX320](http://images.icecat.biz/img/gallery_mediums/77190520_9591890324.jpg)
![Samsung P410M](http://images.icecat.biz/img/gallery_mediums/img_3795453_medium_1481101429_6334_23568.jpg)
