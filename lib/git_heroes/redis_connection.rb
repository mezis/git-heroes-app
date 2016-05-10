require 'singleton'
require 'redis-namespace'
require 'connection_pool'

module GitHeroes
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
        @_redis ||= redis_connection 'data', ENV.fetch('REDIS_URL')
      end

      def redis_sidekiq_pool
        @_redis_sidekiq_pool ||= ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE'), timeout: 1) do
          redis_connection 'sidekiq', ENV.fetch('REDIS_URL')
        end
      end

      def redis_cache_pool
        @_redis_cache_pool ||= ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE'), timeout: 1) do
          redis_connection 'cache', ENV.fetch('REDIS_CACHE_URL')
        end
      end

      def locks
        @_redlock ||= Redlock::Client.new([redis])
      end

      private

      def redis_connection(namespace, url)
        namespace = "#{ENV.fetch 'REDIS_NAMESPACE'}:#{namespace}"
        Redis::Namespace.new(
          namespace,
          redis: Redis::Store::Factory.create(url: url)
        )
      end
    end
  end
end
