class RedisModel
  include ActiveModel::Validations
  Invalid = Class.new(StandardError)
  
  def initialize(options = {})
    @persisted =  options.fetch(:persisted, false)
  end

  def persisted?
    !!@persisted
  end

  def lock
    Rails.application.locks.lock!(_key_lock, 3_600) { yield self }
  end

  def save
    return false unless valid?
    yield if block_given?
    @persisted = true
    self
  end

  def save!
    raise Invalid unless save
    self
  end

  def destroy
    return self unless @persisted
    yield if block_given?
    @persisted = false
    self
  end

  private

  def _key_lock
    _key 'lock', (yield if block_given?)
  end

  def _key_prefix
    @_key_prefix ||= self.class.name.underscore
  end

  module ClassMethods
    def _key_prefix
      @_key_prefix ||= self.name.underscore
    end
  end
  extend ClassMethods

  module SharedMethods
    def _key(*args)
      [ _key_prefix, *args ].flatten.compact.join(':')
    end

    def _key_id(id)
      _key 'by_id', id
    end

    def _redis
      Rails.application.redis
    end
  end
  extend SharedMethods
  include SharedMethods

end
