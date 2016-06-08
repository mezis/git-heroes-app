class AuthenticationToken
  include RedisModel::Attributable
  
  MAX_USES = 5
  EXPIRY = 1.day

  attr_accessor :uses
  attr_reader :user

  validates_presence_of :user
  validates_inclusion_of :uses, in: 1..MAX_USES

  def initialize(options = {})
    super
    @id ||= generate_token
    @uses ||= MAX_USES
  end

  def attribute_names
    %i[uses user]
  end

  def expires_at
    return unless persisted?
    @expires_at ||= begin
      ttl = _redis.ttl(_key_id)
      ttl < 0 ? nil : (Time.current + ttl)
    end
  end

  def expired?
    return true if expires_at.nil?
    expires_at <= Time.current
  end

  def decrement!
    @uses -= 1
    if uses <= 0
      destroy
    else
      save!
    end
    self
  end

  def save
    super do |m|
      m.expire(_key_id, EXPIRY) unless persisted?
    end
  end

  module ClassMethods
    def delete_all
      cursor = 0
      loop do
        cursor, keys = _redis.scan(cursor, match: "#{_key_prefix}:*")
        break if Integer(cursor) == 0
        next if keys.empty?
        _redis.del(*keys)
      end
    end
  end
  extend ClassMethods


  private

  def generate_token
    SecureRandom.urlsafe_base64(30)
  end

end
