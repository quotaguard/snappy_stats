require "snappy_stats/version"

require 'redis'
require 'active_support/time'
require 'snappy_stats/config'

class SnappyStats

  GRANULARITIES = {
    # Available for 24 hours
    minute: {
      size:   1440,
      ttl:    172800,
      factor: 60
    },
    # Available for 7 days
    hour: {
      size:   168,
      ttl:    1209600,
      factor: 3600
    },
    # Available for 24 months
    day: {
      size:   365,
      ttl:    63113880,
      factor: 86400
  }  
}

attr_accessor :config

def initialize(options = {})
 @config = SnappyStats::Config.new
 @config.redis = options[:redis]
 @granularities = options[:granularities]
end

def hash_key
 "#{config.namespace}"
end

def configure
  yield(config)
end

def connection
  @connection ||= config.redis
end

def granularities
  @granularities || GRANULARITIES
end

def getSecondsTimestamp
  Time.now.getutc.to_i
end

def getRoundedTimestamp( ts , precision )
  ts = ts || self.getSecondsTimestamp
  precision = precision || 1
  ( ts / precision ).floor * precision
end

def getFactoredTimestamp( ts_seconds, factor )
  ts_seconds = ts_seconds ||  self.getSecondsTimestamp
  ( ts_seconds / factor ).floor * factor
end

def recordHitNow(key)
  recordHit(Time.now.utc.to_i, key)
end

def recordHit( time, key )
  granularities.keys.each do | gran |
    granularity = granularities[gran]
    size = granularity[:size]
    factor = granularity[:factor]
    ttl = granularity[:ttl]
    tsround = getRoundedTimestamp(time, size * factor)
    redis_key = "#{hash_key}:#{key}:#{gran}:#{tsround}"
    ts = getFactoredTimestamp time, factor
    connection.pipelined{
      connection.hincrby redis_key, ts, 1     
      connection.expireat redis_key, tsround + ttl      
    }
  end
end

def get(gran, from, to, key)     
  granularity = granularities[gran]
  size = granularity[:size]
  factor = granularity[:factor]

  from = getFactoredTimestamp( from, factor )
  to   = getFactoredTimestamp( to, factor )

  ts = from
  i = 0
  results = {}
  current_key = ""
  data = nil
  while ts <= to        
    tsround = getRoundedTimestamp( ts, size * factor )
    redis_key  = "#{hash_key}:#{key}:#{gran}:#{tsround}"
    if(current_key != redis_key)
      data = connection.hgetall( redis_key )
      current_key = redis_key
    end
    results[ts] = data[ ts.to_s ]
    i = i+1 
    ts = ts + granularities[gran][:factor]
  end
  results
end

end
