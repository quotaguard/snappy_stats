require "snappy_stats/version"

require 'redis'
require 'active_support/time'
require 'snappy_stats/config'

module SnappyStats

  GRANULARITIES = {
		# Available for 24 hours
    minute: {
      size:   1440,
      ttl:    172800,
      factor: 60
		},
    hour: {
    # Available for 7 days
      size:   168,
      ttl:    1209600,
      factor: 3600
		},
    day: {
    # Available for 24 months
      size:   365,
      ttl:    63113880,
      factor: 86400
    }  
 	}

 	def self.hash_key
 		"#{SnappyStats.config.namespace}"
 	end

  def self.configure
    yield(config)
  end

  def self.config
    Config
  end

  def self.connection
    @connection ||= config.redis
  end
  
  def self.getSecondsTimestamp
    Time.now.getutc.to_i
  end

  def self.getRoundedTimestamp( ts , precision )
    ts = ts || self.getSecondsTimestamp
    precision = precision || 1
    ( ts / precision ).floor * precision
  end
  
  def self.getFactoredTimestamp( ts_seconds, factor )
    ts_seconds = ts_seconds ||  self.getSecondsTimestamp
    ( ts_seconds / factor ).floor * factor
  end
  
  def self.recordHitNow(key)
    self.recordHit(Time.now.utc.to_i, key)
  end

  def self.recordHit( time, key )
    GRANULARITIES.keys.each do | gran |
      granularity = GRANULARITIES[gran]
      size = granularity[:size]
      factor = granularity[:factor]
      ttl = granularity[:ttl]
      tsround = SnappyStats.getRoundedTimestamp(time, size * factor)
      redis_key = "#{hash_key}:#{key}:#{gran}:#{tsround}"
      ts = getFactoredTimestamp time, factor
      SnappyStats.connection.hincrby redis_key, ts, 1     
      SnappyStats.connection.expireat redis_key, tsround + ttl      
    end
  end

    def self.get(gran, from, to, key)
      granularity = GRANULARITIES[gran]
      size = granularity[:size]
      factor = granularity[:factor]

      from = self.getFactoredTimestamp( from, factor )
      to   = self.getFactoredTimestamp( to, factor )
      
      ts = from
      i = 0
      results = {}
      while ts <= to        
        tsround = getRoundedTimestamp( ts, size * factor )
        redis_key  = "#{key}:#{gran}:#{tsround}"

        results[ts] = SnappyStats.connection.hget( redis_key, ts )
        i = i+1 
        ts = ts + GRANULARITIES[gran][:factor]
      end
      results
    end

    config.init!
end