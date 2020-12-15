# Fourth Kata: How to Gather Human Judgements

We've done basic Searchandizing by fixing _notebook_ and _laptop_ queries, however we're realizing that as we make changes to our core algorithem that we are risking getting to a point where we make changes that have unintended side effects.  The dreaded [Whac-A-Mole](https://en.wikipedia.org/wiki/Whac-A-Mole) game.  We also are realizing that we need to extract from the heads of our team a definition of what good search looks like.  Ideally we would use our customers, but in place of actual customers, we'll work with our customer support team to build out some *judgements*, to function as our test data set for measure relevancy.  

You'll recall that in Kata 001: Optimize a Query we actually did set up a case with the _laptop_ and _notebook_ queries.  However, lets now do slightly more comprehensive set of ratings.   We have [sourced a list of 125 queries](https://docs.google.com/spreadsheets/d/1y8ZS53CdHtTcSVPVTqnysQOGRtd7uRKvmKlj3RztEsA/edit?usp=sharing) that represent a broad set of queries on Chorus Electronics.  (In the real world we would source them from query logs!)

We'll use this subset of the full query set as a starting point:

bluetooth speaker
surround sound speakers
phone case
garmin
gps watch
flat screen tv
computer
laptop bag
gaming mouse
gaming keyboard

Go ahead and create a new case by opening up Quepid and choosing from the _Relevancy Cases_ dropdown the _Create a Case_ option.  Go through the wizard, setting up the case similar to how we did it before, but DON'T put any queries in.  Once the Case shows up, go ahead and cut'n'paste the above queries and paste them in the _Add a query to this case_ text bar, and each return delimited query should show up as a query.  This is a secret Easter Egg in Quepid ;-).

Now, we want to go through and think about what the Information Need is for each query.   I like to list the Information Need at the top of the notes for each Query, to remind myself (and others!) what we thought the end user was looking for.

For example, the query _bluetooth speaker_ is a simple:

> Information Need: I want portable speakers that connect via bluetooth to a device.

Go through each of the ten queries and come up with the information need.  Yes, this is dull, it's the "eat your vegetables" part of Relevancy Tuning.   Do it as a group activity to make it easier!   To make your life easier, I've [done it for the above queries](https://docs.google.com/spreadsheets/d/1y8ZS53CdHtTcSVPVTqnysQOGRtd7uRKvmKlj3RztEsA/edit#gid=648474003).
