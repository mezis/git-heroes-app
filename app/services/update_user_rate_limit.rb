class UpdateUserRateLimit
  def initialize(user:, headers:)
    @user = user
    @headers = headers
  end

  def run
    return unless x_ratelimit_limit = @headers['x-ratelimit-limit']
    return unless x_ratelimit_remaining = @headers['x-ratelimit-remaining']
    return unless x_ratelimit_reset = @headers['x-ratelimit-reset']

    @user.throttle_limit    = x_ratelimit_limit.to_i
    @user.throttle_left     = x_ratelimit_remaining.to_i
    @user.throttle_reset_at = Time.zone.at(x_ratelimit_reset.to_i)
    @user.save!
  end
end
