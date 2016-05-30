class AuthenticationToken < RedisModel
  MAX_USES = 100
  EXPIRY = 1.day

  attr_accessor :uses
  attr_reader :token, :user_id

  validates_presence_of :token, :user_id
  validates_inclusion_of :uses, in: 1..MAX_USES

  def initialize(options = {})
    super
    @token = options.fetch(:token) { generate_token }
    @user_id = options.fetch(:user_id)
    @uses = Integer(options.fetch(:uses, MAX_USES))
  end

  def user
    @user ||= User.find_by(id: @user_id)
  end

  def expires_at
    return unless persisted?
    @ttl ||= begin
      ttl = _redis.ttl(_key_id(@token))
      ttl < 0 ? nil : (Time.current + ttl)
    end
  end

  def expired?
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
    super do
      _redis.multi do |m|
        m.hmset(_key_id(@token), 'uses', @uses, 'user_id', @user_id)
        m.expire(_key_id(@token), EXPIRY) unless persisted?
      end
    end
  end

  def destroy
    super do
      _redis.del(_key_id(@token))
    end
  end

  module ClassMethods
    def create!(options = {})
      new(options).tap(&:save!)
    end

    def find_by(token:)
      data = _redis.hgetall(_key_id(token))
      return if data.empty?
      attrs = data.symbolize_keys.reverse_merge(token: token, persisted: true)
      new(attrs)
    end
  end
  extend ClassMethods


  private

  def generate_token
    SecureRandom.urlsafe_base64(30)
  end

end
