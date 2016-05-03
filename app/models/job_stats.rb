class JobStats
  include ActiveModel::Validations
  Invalid = Class.new(StandardError)
  
  attr_accessor :attempts, :status
  attr_reader   :id, :actor_id, :args_hash, :job_class

  validates_presence_of :id, :args_hash
  validates_numericality_of :attempts

  def initialize(options = {})
    # Rails.logger.info options.inspect
    @id =         options.fetch(:id)
    @job_class =  options.fetch(:job_class)
    @args_hash =  options.fetch(:args_hash)
    @status =     options.fetch(:status, nil)
    @actor_id =   options.fetch(:actor_id, nil)
    @attempts =   Integer(options.fetch(:attempts, 0))
    @persisted =  options.fetch(:persisted, false)
  end

  def attributes
    Hash[
      %i[job_class args_hash actor_id attempts status].map { |a| [a, public_send(a)] }
    ]
  end

  def persisted?
    !!@persisted
  end

  def lock
    Rails.application.locks.lock!(_key_lock, 3_600) { yield self }
  end

  def duplicate?
    [nil, @id].exclude? _redis.get(_key_uniq)
  end

  def save
    return false unless valid?
    _redis.multi do
      _redis.sadd(_key_actor(@actor_id), @id)
      _redis.hmset(_key_id(@id), *attributes.to_a.flatten)
      _redis.set(_key_uniq, @id)
    end
    @persisted = true
    self
  end

  def save!
    raise Invalid unless save
    self
  end

  def destroy
    return self unless @persisted
    _redis.multi do
      _redis.srem(_key_actor(@actor_id), @id)
      _redis.del(_key_id(@id))
      _redis.del(_key_uniq)
    end
    @persisted = false
    self
  end

  private

  def _key_uniq
    "job:uniq:#{@job_class}:#{@args_hash}"
  end

  def _key_lock
    "job:lock:#{@job_class}:#{@args_hash}"
  end

  module ClassMethods
    def find_or_initialize_by(job:)
      data = _redis.hgetall(_key_id(job.job_id))
      attrs = data.symbolize_keys.reverse_merge(
        id:        job.job_id,
        actor_id:  job.arguments.dup.extract_options![:actor_id],
        job_class: job.class.name,
        args_hash: Digest::MD5.hexdigest(job.arguments.to_json)
      )
      attrs[:persisted] = true if data.any?
      new(attrs)
    end

    def where(actor:nil)
      actor_key = _key_actor(actor&.id)
      _redis.smembers(actor_key).lazy.map { |id|
        data = _redis.hgetall(_key_id(id))
        unless data && data.any?
          _redis.srem(actor_key, id)
          next
        end
        new(data.symbolize_keys.merge(id: id, persisted: true))
      }.select(&:present?)
    end
  end
  extend ClassMethods

  module SharedMethods
    def _key_id(job_id)
      "job:by_id:#{job_id}"
    end

    def _key_actor(actor_id)
      "job:#{actor_id ? actor_id : 0}"
    end

    def _redis
      Rails.application.redis
    end
  end
  extend SharedMethods
  include SharedMethods
end
