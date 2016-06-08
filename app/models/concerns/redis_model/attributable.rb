module RedisModel
  module Attributable
    extend ActiveSupport::Concern
    include Base
    include Validable

    included do
      attr_reader :id
      validates_presence_of :id
    end

    def initialize(options = {})
      super
      options.each_pair do |key, value|
        instance_variable_set :"@#{key}", value
      end
      @orignal_attributes = persisted? ? attributes : {}
    end

    def attributes
      Hash[
        attribute_names.map { |attr| [attr, public_send(attr)] }
      ]
    end

    def changes
      result = {}
      attributes.each_pair do |k,v|
        original = @orignal_attributes[k]
        next unless v != original
        result[k] = [original, v]
      end
      result
    end

    def save
      super do |m|
        m.set _key_id, serializer.dump(attributes)
        yield m if block_given?
      end
    end

    def destroy
      super do |m|
        m.del(_key_id)
        yield m if block_given?
      end
    end

    module ClassMethods
      def find(id)
        data = _redis.get(_key_id(id))
        return if data.blank?
        new serializer.load(data).merge(id: id, persisted: true)
      end

      protected

      def serializer
        SerializationService.new
      end

      private

      def _key_id(id)
        _key 'id', id
      end
    end

    protected

    def attribute_names
      raise NotImplementedError
    end


    def _key_id
      _key 'id', @id
    end

    private

    def serializer
      self.class.send(:serializer)
    end
  end
end
