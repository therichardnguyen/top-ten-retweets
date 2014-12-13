top-ten-retweets
================

A coding problem

Use Twitter's sample streaming API to show the top 10 retweeted tweets (note the retweeted_status field) in a rolling window of time, where the window's start is n minutes ago (where n is defined by the user) and the window's end is the current time.

Output should continuously update and include the tweet text and number of times retweeted in the current rolling window. You should not use the retweet_count field, but instead count the retweets that your program actually processes.
 
To expedite things, feel free to use the following Twitter credentials: [redacted]

Please host your code on GitHub.

How does it work?

I leverage the 'twitter' gem to access the Twitter sample stream endpoint as well as parse the JSON.

For every tweet found in the stream:
	if it's a retweet:
		if we've seen the original tweet already:
			add a retweet sighting
		otherwise
			create a new retween sighting and add it to the retweet sighting hash
		
		Prune all the sightings of any sighting before n-minutes ago
		
		Sort sightings by count and print out the top 10
		
		
Issues:

- Memory footprint grows unchecked.

- O(n^2) run time where n is the number of tweets retweeted. For each retweet we find, we touch every retweet we know about at least once. 
