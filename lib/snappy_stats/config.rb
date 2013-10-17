module SnappyStats
  module Config
    extend self
    
    attr_accessor :namespace
    attr_accessor :raise_connection_errors
    
    def init!  
      # all keys are prefixed with this namespace
      self.namespace = 'stats'
      # rescue Redis connection errors
      self.raise_connection_errors = false      
    end

    # Set the Redis connection to use
    #
    # arg - A Redis connection or a Hash of Redis connection options
    #
    # Returns the Redis client
    def redis=(arg)
      if arg.is_a? Redis
        @redis = arg
      else
        @redis = Redis.new(arg)
      end
    end

    # Returns the Redis connection
    def redis
      @redis ||= Redis.new
    end
  end
end
