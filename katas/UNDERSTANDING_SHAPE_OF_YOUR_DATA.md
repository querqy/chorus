# Third Kata: Understanding the Shape of Your Data

Ecommerce tends to have lots of strongly attributed data compared to traditional full text search.  Sure, we have the obvious attributes like product name, manufacturer, and price.  However there are also colour, fit, style, material type. Our Icecat dataset has more than 8000 unique attributes associated with the product data set:

>> curl "http://localhost:8983/solr/ecommerce/admin/luke?numTerms=0&wt=json"  | grep attr_ | grep -v dynamicBase

Not sure what `attr_t_yogurt_maker_programs` is all about ;-).

A common pattern is to choose to list out facets for your products that match

* Look at all 8000+ facets and the distribution of them.
