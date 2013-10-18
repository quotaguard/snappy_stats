require 'spec_helper'

describe SnappyStats do

	before(:all) do
		#Redis::Connection.drivers.delete_if {|x| Redis::Connection::Memory == x }
		keys = SnappyStats.connection.keys("stats:*")
		keys.each { | key | SnappyStats.connection.del(key) }
	end

  it "Calculates ts in seconds" do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    time = SnappyStats.getSecondsTimestamp
  	expect(time).to be 1357002060  	
  	default_rounded = SnappyStats.getRoundedTimestamp(nil, 60)
  	expect(default_rounded).to be 1357002060  	  	
  	time = 1364833411 
  	rounded = SnappyStats.getRoundedTimestamp(time, 60)
  	expect(rounded).to be 1364833380 
  end

  it "Records a hit at all granularities" do
      pending("Need updated version of fakeredis with correct hincrby implementation")  	
    Timecop.freeze
    now = Time.now        
    5.times do 
        SnappyStats.recordHitNow("test:counter1")
    end
    3.times do 
        SnappyStats.recordHitNow("test:counter2")
    end       
    Timecop.freeze(now + 2.days) 
    2.times do 
        SnappyStats.recordHitNow("test:counter1")
    end
    from = now.midnight.to_i
    to = (now.midnight + 2.day).to_i
    daily_user1_stat = SnappyStats.get(:day,from,to,"test:counter1")
    Timecop.freeze(now + 1.day)
    puts daily_user1_stat
    expect(daily_user1_stat[from]).to eq("5")
    hourly_user1_stat = SnappyStats.get(:hour,from,to,"test:counter1")
    expect(hourly_user1_stat[ Time.now.beginning_of_hour.to_i]).to eq("5")
    daily_user2_stat = SnappyStats.get(:day,from,to,"test:counter2")
    expect(daily_user2_stat[from]).to eq("3")    
  end

  after(:each) do
    	Timecop.return
  end
end