# Second Kata: Lets Predict the Product Category

Single term queries can be tough for a search engine to understand query intent, and yet easy for a person to understand.  For example, on _Chorus Electronics_ we understand that a query like _notebook_ is probably about laptop computers.   If we were shopping at _Chorus Bookstore_, then we would expect to see writing notebooks.  On a general merchandize site like Amazon, we would know that a query like _notebook_ would return both of those categories of products!  Thats a great example of how our understanding of the brand of the ecommerce site influeneces what we expect to see.   

However, our poor search engine only knows that the token _notebook_ shows up in a wide variety of different products.  Search for _notebook_ on http://localhost:4000 and you will get back more than 13 thousand products!  Due to our somewhat crummy relevance we are seeing lots of backpacks for notebook computers and other accessories.  Flip open the Product Type facet, and you'll see:

| Product Type  |  Count |
|---|---|
| Notebook  | 6482  |
| Hybrid (2-in-1)  | 28  |
| Netbook  |  18 |
| Chromebook  | 14  |

This suggests that if we can just "click" the Notebook product type, we'll increase our precision greatly, and return better results.

However, we can't just blindly click the most common Product Type.  Let's look at another query, _filter_.   There are many types of filters, for your refrigerator water dispenser, for a pond, for a coffee maker.  And confusingly, it also shows up in the description of 30 different notebooks.
