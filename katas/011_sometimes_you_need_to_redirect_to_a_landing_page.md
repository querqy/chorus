# Eleventh Kata: Sometimes You Need to Redirect to a Landing Page

<i><a href="PLACEHOLDER: https://opensourceconnections.com/blog/2020/blah/blah" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

Sometimes the right answer to a user's question isn't to actually run a search, but instead to drop them on the perfect page for them.  

Redirect rules bypass the normal search results and redirect the page to a specific URL when the search query is entered. This is useful for terms that are very broad or for non-product searches.

For example, a search for _computer_ can redirect to the computers category. Because the term computer is very broad, redirecting the user to the category page allows them to browse subcategories of computers to find a specific type of computer.

Another example is a search for _employment_. Since an ecommerce site typically only indexes the product catalog, a redirect is necessary to send users to the careers page for this search.

 __Active Search Management capability has been the biggest feature that commercial engines have had over the open source options for many years ;-)  With open source tools like Querqy which is part of the Chorus stack, Lucene-based search engines have closed this gap for good.__

In this Kata we're going to walk you through creating a REDIRECT rule in SMUI, and we'll call out the bit of code that makes the redirection work.

Assuming you've fired up Chorus via `quickstart.sh -lab`, go ahead and open up the web store at  http://localhost:4000/ a search for _returns_.  
You'll see a bunch of terrible search results.  However, we know that the perfect search result, the returns policy landing page at http://localhost:4000/returns-policy.html is out there.  So how can we get our users to that page?  

Open up SMUI at http://localhost:9000 and create a new rule for the query _returns_.  
Pick _Rule Management_ and from the drop down for new search rules pick _REDIRECT Rule_.
This brings up a place for you to put in your redirect url.  Go ahead and put in `/return-policy.html`.  
Oh, and don't forget a comment like "users are looking for information on how to do returns" to capture what you think the information need is ;-).

Go ahead and save and push the configuration up.

Now, go back to the web shop, and making sure you've chosen the  _Querqy Prelive_ algorithm, repeat your search for _returns_.  
Tada!  You are redirected to the web page that details everything you need to know to return products on the Chorus Electronics webshop!

So let's learn a bit more about how this all works.  When you do a search that matches on a REDIRECT rule, then Querqy decorates the response with additional information about the redirect, as well as the ID of the rule that was applied:

```
{
  "querqy_decorations": ["REDIRECT /return-policy.html"],
	"querqy.infoLog": {
		"common_rules_prelive": [{
			"APPLIED_RULES": ["19cc1fc3-5320-4b8f-a7a2-0ba8f44e6ece"]
		}]
	}
}
```  

Here you can see the Solr response for yourself:

http://localhost:8983/solr/ecommerce/select?q=returns&useParams=visible_products,querqy_algo_prelive&echoParams=all&fl=id%20title&wt=json&debug=true&debug.explain.structured=true&indent=true&echoParams=all

Your web layer is going to need to receive this information so that it can redirect the user instead of rendering the typical results page.  Since we are using an existing front end tool called Blacklight, we had to kind of "hack" our way in by layering our logic into the existing Pagination component.

You can see the check for the return of the REDIRECT rule here https://github.com/querqy/chorus/blob/demo_redirect/blacklight/app/components/blacklight/response/pagination_component.rb#L14.  The `@redirect_url` is then passed to the HTML rendered view to drive a Javascript based redirect https://github.com/querqy/chorus/blob/demo_redirect/blacklight/app/components/blacklight/response/pagination_component.html.erb#L10.

Notice how we did a basic redirect?  If your redirection is a fully qualified url, like `http://example.com` then you will redirect to that website instead.

To wrap up this kata, go ahead and try some queries like _returns policy_ and _how do I do returns_ and you'll see they redirect the way you expect.
However if you try out _return policy_ you will be disappointed, and that is because Querqy doesn't match that token.   You have two options...  

First you could just add a REDIRECT for _return_.

Alternatively you could change the query to `retur*`.  The `*` means match 1 or more characters, so `return*` will NOT match the query `return`.

Lastly, remember, that this rule is going to kick in for any query that has the words _return_ or _returns_, so it would be wise to check your user query logs ;-).  For example, if a *Return Shelf* is a product you sell, then you would need to deal with this.  
