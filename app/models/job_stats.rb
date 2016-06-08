class JobStats
  include RedisModel::Base
  include RedisModel::Lockable
  include RedisModel::Attributable

  attr_accessor :attempts, :status
  attr_reader   :actors, :args_hash, :job_class, :enqueued_at

  validates_presence_of :id, :args_hash
  validates_numericality_of :attempts

  def initialize(options = {})
    super
    @actors       = [@actors].flatten.compact
    @attempts     ||= 0
    @enqueued_at  ||= Time.current.to_i
  end

  def attribute_names
    %i[job_class args_hash actors attempts status]
  end

  def duplicate?
    !!_redis.sismember(_key_uniq, @args_hash)
  end

  def save
    super do |m|
      _actors_sentinel.each do |actor|
        m.sadd(_key_actor(actor), @id)
      end
      m.sadd(_key_uniq, @args_hash)
    end
  end

  def destroy
    super do |m|
      _actors_sentinel.each do |actor|
        m.srem(_key_actor(actor), @id)
      end
      m.srem(_key_uniq, @args_hash)
    end
    self
  end

  private

  def _key_uniq
    _key 'uniq', @job_class
  end

  def _key_lock
    super { [@job_class, @args_hash] } 
  end

  def _actors_sentinel
    @actors.any? ? @actors : [nil]
  end

  module ClassMethods
    def find_or_initialize_by(job:)
      find(job.job_id) ||
      new(
        id:        job.job_id,
        actors:    job.arguments.dup.extract_options![:actors],
        job_class: job.class.name,
        args_hash: Digest::MD5.hexdigest(job.arguments.to_json)
      )
    end

    # lazily enumerated!!
    def where(actor: nil)
      actor_key = _key_actor(actor)
      _redis.smembers(actor_key).lazy.map { |id|
        obj = find(id)
        _redis.srem(actor_key, id) unless obj.present?
        obj
      }.select(&:present?)
    end
  end
  extend ClassMethods

  module SharedMethods
    def _key_actor(actor)
      case actor
      when ActiveRecord::Base
        _key 'actor', actor.class.name, actor.id
      else
        _key 'actor', serializer.dump(actor)
      end
    end
  end
  extend SharedMethods
  include SharedMethods
end
