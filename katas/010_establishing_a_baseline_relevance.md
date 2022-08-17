# Tenth Kata: Establishing a Baseline Metric for Relevancy

<i><a href="https://opensourceconnections.com/blog/2020/10/19/pete-estabalishes-a-baseline/" target="_BLANK">Read the blog, watch the video version of this Kata</a></i>

At this point, you are probably starting to see that the butterfly effect has a very powerful impact on your relevancy tuning efforts.  For those you aren't familiar with the term, the butterfly effect is:

> is the idea that small, seemingly trivial events may ultimately result in something with much larger consequences – in other words, they have non-linear impacts on very complex systems. For instance, when a butterfly flaps its wings in India, that tiny change in air pressure could eventually cause a tornado in Iowa.  https://science.howstuffworks.com/math-concepts/butterfly-effect.htm

Where we see this in our relevancy tuning is that you improve the results for one query, and yet that has unanticipated impacts on many other queries.   Some times the unanticipated impacts are a pleasant surprise, improving many other queries.  More commonly, the optimal solution for one query has some negative impact on other queries.    

To deal with this, to use the old phrase, we need to look at the forest, not the trees, and we do this via a Baseline Relevancy Case in Quepid.

The Baseline Relevancy Case is a set of queries that represents the typical queries we are getting.   You can source them from your query logs, and it should have queries that come from both your Head and your Long Tail of queries that users are running.   

Once you have those queries defined, make sure you get them

   We need to create a Baseline Relevancy Case in Quepid that lets us understand the impact of changes to a query (the tree), as well as understand it over a representative

- what is  abaseline

- reference how we got the data.

- talk about establishing a snapshot and an annotation for baseline.
