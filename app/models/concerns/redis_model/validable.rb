module RedisModel
  module Validable
    extend ActiveSupport::Concern
    include Base
    
    included do
      const_set :Invalid, Class.new(StandardError)
      include ActiveModel::Validations
    end

    def save
      super do |m|
        return false unless valid?
        yield m if block_given?
      end
    end

    def save!
      raise Invalid, errors.full_messages unless save
      self
    end
  end
end
