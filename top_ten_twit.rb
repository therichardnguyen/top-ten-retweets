require 'twitter'
require 'active_support/all'

#Keep track of a tweet
class RetweetSightings
  # store the text  
  def initialize
    @seen_at = []
  end
  
  def count
    @seen_at.length
  end
  
  def add_sighting(date)
    @seen_at.push(date)
  end
  
  def oldest_sighting
    @seen_at.first
  end
  
  def prune_sightings(before_date)
    @seen_at.delete_if { |date| date < before_date}
  end
end

#Configure the twitter client
client = Twitter::Streaming::Client.new do |config|
  config.consumer_key       = 'BEyMdaCNuItG43aoJuGlyBPHu'
  config.consumer_secret    = 'Z7rnIKvAGv2KEykPDwhRtRbuyo8uWsx2qDAfulWS9uLdQ40nh1'
  config.access_token        = '2823769104-PUGMstxdznlEvLKe5zhHa0UzTpGbdO1LNZuCVoo'
  config.access_token_secret = '5upCsHJrd3iuAnZuGqdo4k6AVAxAqTkCAeu8xfKmNBReq'
end

# Ask about the parameters
n = 10  # default 10 minutes

puts "How big should the window be?"
n = gets.chomp.to_i

puts "Working with rolling window of #{n} minutes."

# do the work
@retweet_sightings = Hash.new

puts @retweet_sightings

client.sample do |tweet|
  
  # Only use twitter:: Tweets since 'sample' also yields 
  #Twitter::Tweet, Twitter::Streaming::Event, Twitter::DirectMessage, Twitter::Streaming::FriendList, Twitter::Streaming::DeletedTweet, Twitter::Streaming::StallWarning
  if tweet.kind_of? Twitter::Tweet
    original_tweet = tweet.retweeted_tweet
    
    # If this is a retweet, Also might be null, so just make sure
    if original_tweet.kind_of? Twitter::Tweet
      
      # If we've seen the original_tweet before, just add the sighting
      if @retweet_sightings.has_key?(original_tweet.text)
        sighting = @retweet_sightings[original_tweet.text]
        sighting.add_sighting(DateTime.now)
        
      # otherwise it's new sighting
      else
        # Creating a new retweet sighting and add it to the sightings
        sighting = RetweetSightings.new
        sighting.add_sighting(DateTime.now)
        @retweet_sightings[original_tweet.text] = sighting
      end
      
      # prune the sightings
      oldest_desired_sighting = n.minutes.ago
      @retweet_sightings.each do |key,value|
        value.prune_sightings(before_date=oldest_desired_sighting)
      end

      # Sort the retweets by count
      sorted_tweets = @retweet_sightings.sort_by{|k,v| v.count}
      
      # print the top 10 tweets
      puts "Current top 10 tweets in window [#{oldest_desired_sighting} - #{DateTime.now}]:"
      counter = 1
      sorted_tweets.last(10).reverse.each do |tweet|
        puts "#{counter} - [Count: #{tweet[1].count}] ; \"#{tweet[0]}\" (oldest sighting: #{tweet[1].oldest_sighting})"
        counter += 1
      end
      puts "===================================="
    end
  end
end