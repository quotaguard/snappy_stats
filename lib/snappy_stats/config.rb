class SnappyStats
  class Config
    
    attr_accessor :namespace
    attr_accessor :raise_connection_errors
    
    def initialize(options = {})
      # all keys are prefixed with this namespace
      @namespace = 'stats'
      # rescue Redis connection errors
      @raise_connection_errors = false      
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
