require 'spec_helper'

require_relative '../lib/snappy_stats'
describe SnappyStats do

	before(:each) do
    redis = Redis.new
    $snappy_stats = SnappyStats.new(:redis => redis)
		#Redis::Connection.drivers.delete_if {|x| Redis::Connection::Memory == x }
		keys = $snappy_stats.connection.keys("stats:*")
		keys.each { | key | $snappy_stats.connection.del(key) }
	end

  it "Calculates ts in seconds" do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    time =  $snappy_stats.getSecondsTimestamp
  	expect(time).to be 1357002060  	
  	default_rounded =  $snappy_stats.getRoundedTimestamp(nil, 60)
  	expect(default_rounded).to be 1357002060  	  	
  	time = 1364833411 
  	rounded =  $snappy_stats.getRoundedTimestamp(time, 60)
  	expect(rounded).to be 1364833380 
  end

  it "Records a hit at all granularities" do    
    Timecop.freeze
    now = Time.now        
    starting_hour = Time.now.beginning_of_hour.to_i
    5.times do 
        $snappy_stats.recordHitNow("test:counter1")
    end
    3.times do 
        $snappy_stats.recordHitNow("test:counter2")
    end       
    Timecop.freeze(now + 2.days) 
    2.times do 
        $snappy_stats.recordHitNow("test:counter1")
    end
    from = now.midnight.to_i
    to = (now.midnight + 2.day).to_i
    daily_user1_stat = $snappy_stats.get(:day,from,to,"test:counter1")
    Timecop.freeze(now + 1.day)
    expect(daily_user1_stat[from]).to eq("5")
    hourly_user1_stat = $snappy_stats.get(:hour,from,to,"test:counter1")
    expect(hourly_user1_stat[ starting_hour.to_i]).to eq("5")
    daily_user2_stat = $snappy_stats.get(:day,from,to,"test:counter2")
    expect(daily_user2_stat[from]).to eq("3")    
  end

  it "can have two versions at same time" do
    redis1 = Redis.new(db: 1)  
    $snappy_stats_eu =  SnappyStats.new(:redis => redis1)
    from = Time.now.midnight.to_i
    to = (Time.now.midnight + 2.day).to_i
    500.times do 
        $snappy_stats.recordHitNow("test:counter1")
    end
    250.times do 
        $snappy_stats_eu.recordHitNow("test:counter2")
    end    
    user1_stats = $snappy_stats.get(:day,from,to,"test:counter1")
    expect(user1_stats[from]).to eq("500")
    user2_stats = $snappy_stats_eu.get(:day,from,to,"test:counter2")
    expect(user2_stats[from]).to eq("250")
  end

  after(:each) do
    	Timecop.return
  end
end