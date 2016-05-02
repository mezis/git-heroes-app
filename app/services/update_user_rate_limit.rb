class UpdateUserRateLimit
  def initialize(user:, rate_limit:)
    @user = user
    @rate_limit = rate_limit
  end

  def run
    @user.throttle_limit    = @rate_limit.limit
    @user.throttle_left     = @rate_limit.remaining
    @user.throttle_reset_at = @rate_limit.resets_at
    @user.save! if @user.changed?
  end
end
