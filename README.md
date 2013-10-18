# snappy_stats [![Build Status](https://travis-ci.org/timrwilliams/snappy_stats.png?branch=master)](https://travis-ci.org/timrwilliams/snappy_stats)

This is a simple Ruby time series statistics gem that uses Redis for storage. Retrieval is optimised for graphing engines by nil filling empty time periods. I graph it with [Rickshaw] (code.shutterstock.com/rickshaw/).

## Installation
Install the gem:

    gem install snappy_stats

Add it to your Gemfile:

    gem "snappy_stats"

## Background
SnappyStats is a Ruby implementation of a simple time series statistics tool based on [ApiAxle's Javascript statistics lib] (http://blog.apiaxle.com/post/storing-near-realtime-stats-in-redis/) which in turn was heavily influenced by [RRDTool] (http://en.wikipedia.org/wiki/RRDtool).

It allows you to store and retrieve simple metrics (think hit counters). The metrics are returned in a set optimised for graphing engines as each time period is represented in the results even if no hit was recorded in that period.

## Usage
    # Record a hit now
    SnappyStats.recordHitNow("test:counter1")
    # Get all results between given timestamp range
    results = SnappyStats.get(:day,Time.now.midnight.to_i,(Time.now.midnight + 1.days).to_i,"test:counter1")

## Detailed Example
    require 'snappy_stats'

    #Using Timecop to simulate changing time, not required in production implementation
    Timecop.freeze
    now = Time.now        

    # Simulate 5 hits for today
    5.times do 
        SnappyStats.recordHitNow("test:counter1")
    end

    # Simulate 5 hits for 2 days from now
    Timecop.freeze(now + 2.days) 
    2.times do 
        SnappyStats.recordHitNow("test:counter1")
    end

    # Decide what range we want to search for
    from = Time.now.midnight.to_i
    to = (Time.now.midnight + 2.days).to_i

    # Get daily results between the from and to timestamps for given key, filling missing days with nil
    daily_stats = SnappyStats.get(:day,from,to,"test:counter1")
    p daily_stats  # {1382054400=>"5", 1382140800=>nil,1382227200=>"2"}

## Configuration
By default SnappyStats uses the current vesion of Redis defined in your project. To use a different Redis use a config initializer.

    # config/initializers/snappy_stats.rb
    SnappyStats.configure do |config|
        # set the Redis connection to a new Redis connection
        config.redis = Redis.new
        # Change Redis key prefix away from default 'stats'
        config.namnespace = "custom_stats"
    end

## Contributing to SnappyStats

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


