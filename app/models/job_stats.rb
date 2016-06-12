class JobStats
  include RedisModel::Base
  include RedisModel::Lockable
  include RedisModel::Attributable
  include RedisModel::Callbacks

  attr_accessor :attempts, :status
  attr_reader   :actors, :args_hash, :job_class, :enqueued_at, :parent_id, :root_id

  validates_presence_of :id, :args_hash
  validates_numericality_of :attempts

  def initialize(options = {})
    super
    @actors       = [@actors].flatten.compact
    @attempts     ||= 0
    @enqueued_at  ||= _timestamp
    @root_id      ||= parent&.root_id || id
  end

  def attribute_names
    super + %i[job_class args_hash actors attempts status parent_id root_id]
  end

  def duplicate?
    !!_redis.sismember(_key_uniq, @args_hash)
  end

  def save
    _ancestors = ancestors # load before the transaction
    super do |m|
      m.sadd(_key_uniq, @args_hash)
      m.zadd(_key_all, @enqueued_at, @id)
      _actors_sentinel.each do |actor|
        m.zadd(_key_actor(actor), @enqueued_at, @id)
      end
      _ancestors.each { |a| a.add_descendant!(self) } unless persisted?
    end
  end

  def destroy
    super do |m|
      m.srem(_key_uniq, @args_hash)
      m.zrem(_key_all, @id)
      _actors_sentinel.each do |actor|
        m.zrem(_key_actor(actor), @id)
      end
      m.hdel(_key_descendants_max, @id)
      m.del(_key_descendants)
    end
    self
  end

  def complete!
    update_attributes!(status: 'done')
    ancestors.each { |a| a.complete_descendant!(self) }
    destroy if !has_descendants?
    self
  end

  def root
    @root ||= @root_id ? self.class.find(@root_id) : nil
  end

  def parent
    @parent ||= @parent_id ? self.class.find(@parent_id) : nil
  end

  def descendants 
    _redis.zrange(_key_descendants, 0, -1)
  end

  def descendants_max
    value = _redis.hget(_key_descendants_max, @id)
    Integer(value || 0)
  end

  def descendants_left
    _redis.zcard(_key_descendants)
  end

  protected

  def add_descendant!(other)
    _redis.multi do |m|
      m.zadd(_key_descendants, other.enqueued_at, other.id)
      m.hincrby(_key_descendants_max, @id, 1)
    end
  end

  def complete_descendant!(other)
    _redis.multi do |m|
      m.zrem(_key_descendants, other.id)
    end
    destroy if !has_descendants? && status == 'done'
  end

  private

  def ancestors
    ancestors = [parent, (root if root_id != id && root_id != parent_id)].compact
  end

  def has_descendants?
    _redis.zcard(_key_descendants) > 0
  end

  def _timestamp
    (Time.current.to_f * 1e9).to_i
  end

  def _key_descendants
    _key 'chld', @id
  end

  def _key_descendants_max
    _key 'chdlcount', @id
  end

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
      find(job.job_id) || begin
        argv = job.arguments.dup
        options = argv.extract_options!

        new(
          id:        job.job_id,
          actors:    options.delete(:actors),
          parent_id: options.delete(:parent)&.job_id,
          job_class: job.class.name,
          args_hash: Digest::MD5.hexdigest(serializer.dump([argv,options]))
        )
      end
    end

    # lazily enumerated!!
    def where(actor: nil)
      actor_key = _key_actor(actor)
      _redis.zrange(actor_key, 0, -1).lazy.map { |id|
        obj = find(id)
        _redis.zrem(actor_key, id) unless obj.present?
        obj
      }.select(&:present?)
    end

    def all
      _redis.zrange(_key_all, 0, -1).lazy.map { |id|
        obj = find(id)
        _redis.zrem(_key_all, id) unless obj.present?
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

    def _key_all
      _key 'all'
    end
  end
  extend SharedMethods
  include SharedMethods
end
