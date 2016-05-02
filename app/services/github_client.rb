require 'net/http/persistent'

class GithubClient
  Throttled = Class.new(StandardError)

  def initialize(user)
    @user = user
  end

  def respond_to_missing?(name, include_private=false)
    client.respond_to?(name, include_private)
  end

  def method_missing(name, *args, &block)
    # consider throttling
    if @user.updated_at > 5.minutes.ago && 
      @user.throttle_left &&
      @user.throttle_left < @user.throttle_limit / 4 &&
      @user.throttle_reset_at > Time.current
      raise Throttled, @user.throttle_reset_at
    end

    # make the call
    result = client.public_send(name, *args, &block)

    # update throttling metadata
    UpdateUserRateLimit.new(user: @user, rate_limit: client.rate_limit).run

    result
  end

  private

  def client
    @client ||= Octokit::Client.new(login: @user.login, password: @user.github_token, middleware: stack)
  end
  
  def stack
    @stack ||= Faraday::RackBuilder.new do |builder|
      builder.use     Faraday::HttpCache,
        store:        Rails.cache, 
        instrumenter: ActiveSupport::Notifications
      builder.use     Octokit::Response::RaiseError
      builder.adapter :net_http_persistent
    end
  end
end
