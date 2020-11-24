# Fourth Kata: How to Gather Human Judgements

We've done basic Searchandizing by fixing _notebook_ and _laptop_ queries, however we're realizing that as we make changes to our core algorithem that we are risking getting to a point where we make changes that have unintended side effects.  The dreaded [Whac-A-Mole](https://en.wikipedia.org/wiki/Whac-A-Mole) game.  We also are realizing that we need to extract from the heads of our team a definition of what good search looks like.  Ideally we would use our customers, but in place of actual customers, we'll work with our customer support team to build out some *judgements*, to function as our test data set for measure relevancy.  

You'll recall that in Kata 001: Optimize a Query we actually did set up a case with the _laptop_ and _notebook_ queries.  However, lets now do slightly more comprehensive set of ratings.   We'll use this set of queries as a starting point:

bluetooth speaker
surround sound speakers
phone case
garmin
gps watch
flat screen tv
computer
laptop bag,
gaming mouse
gaming keyboard

Go ahead and create a new case by opening up Quepid and choosing from the _Relevancy Cases_ dropdown the _Create a Case_ option.  Go through the wizard, setting up the case similar to how we did it before, but DON'T put any queries in.  Once the Case shows up, go ahead and cut'n'paste the above queries and paste them in the _Add a query to this case_ text bar, and each return delimited query should show up as a query.
