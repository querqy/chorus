# Eleventh Kata: Sometimes You Need to Redirect to a Landing Page

<i><a href="PLACEHOLDER: https://opensourceconnections.com/blog/2020/blah/blah" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

Sometimes the right answer to a user's question isn't to actually run a search, but instead to drop them on the perfect page for them.  

We see a very common pattern that among the most common search queries is for someone looking for information about the site they are on, not looking
for what the site delivers.  Think someone looking for the returns policy on an ecommerce website or parking information on a hospital website.  

The way we solve this is to create some redirection rules for specific queries.  __As an aside, this kind Active Search Management capability has been the biggest feature that commercial engines have had over the open source options ;-)__

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
