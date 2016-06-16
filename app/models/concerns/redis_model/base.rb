module RedisModel
  module Base
    extend ActiveSupport::Concern
    
    included do
      extend SharedMethods
      include SharedMethods
    end
  
    def initialize(options = {})
      @persisted = options.fetch(:persisted, false)
    end

    def persisted?
      !!@persisted
    end

    def valid?
      true
    end

    def save
      _redis.multi do |m|
        yield m if block_given?
        m.after_multi do
          @persisted = true
        end
      end
      self
    end

    def destroy
      return self unless @persisted
      _redis.multi do |m|
        yield m if block_given?
        m.after_multi do
          @persisted = false
        end
      end
      self
    end

    protected

    def _key_prefix
      @_key_prefix ||= self.class.name.underscore
    end

    module ClassMethods
      def create!(options = {})
        new(options).tap(&:save!)
      end

      def delete_all
        cursor = 0
        loop do
          cursor, keys = _redis.scan(cursor, match: "#{_key_prefix}:*", count: 100)
          _redis.del(*keys) if keys.any?
          break if Integer(cursor) == 0
        end
      end

      protected

      def _key_prefix
        @_key_prefix ||= self.name.underscore
      end
    end

    module SharedMethods
      protected

      def _key(*args)
        [ _key_prefix, *args ].flatten.compact.join(':')
      end

      def _redis
        Rails.application.redis
      end
    end

  end
end
