require 'singleton'
require 'redis-namespace'
require 'connection_pool'

module GitHeroes
  module RedisTransaction
    # re-entrant transactions
    # not thread-safe
    def multi
      redis.synchronize do |client|
        if @transaction
          yield @transaction
          nil
        else 
          begin
            statuses = super do |m|
              @transaction = m
              @transaction_callbacks = []
              yield m
            end
            @transaction_callbacks.each(&:call)
            statuses
          ensure
            @transaction_callbacks = nil
            @transaction = nil
          end
        end
      end
    end

    def after_multi(&block)
      @transaction_callbacks << block
    end
  end

  module RedisConnection

    %i[redis redis_sidekiq_pool redis_cache_pool locks].each do |m|
      define_method m do |*args|
        Singleton.instance.public_send(m, *args)
      end
    end
    # delegate :redis, :redis_cache_pool, :locks, to: -> { Singleton.instance }

    class Singleton
      include ::Singleton

      def redis
        @_redis ||=
          Redis::Namespace.new('data', redis: Redis.new(url: ENV.fetch('REDIS_URL'))).extend(RedisTransaction)
      end

      def redis_sidekiq_pool
        @_redis_sidekiq_pool ||= ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE'), timeout: 1) do
          Redis::Namespace.new('sidekiq', redis: Redis.new(url: ENV.fetch('REDIS_URL')))
        end
      end

      def redis_cache_pool
        @_redis_cache_pool ||= ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE'), timeout: 1) do
          # redis-store-activerecord expects a Redis::Store which has a slightly
          # nonstandard API
          Redis::Store::Factory.create(namespace: 'cache', url: ENV.fetch('REDIS_CACHE_URL'))
        end
      end

      def locks
        @_redlock ||= Redlock::Client.new([redis])
      end
    end
  end
end
