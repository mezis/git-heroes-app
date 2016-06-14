require 'net/http/persistent'

class GithubClient
  class Throttled < StandardError
    attr_reader :retry_at
    def initialize(retry_at)
      @retry_at = retry_at
    end
  end

  def initialize(user)
    raise ArgumentError, 'user required' if user.nil?
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
    @client ||= Octokit::Client.new(login: @user.login, password: @user.github_token, middleware: stack, user_agent: user_agent)
  end

  def user_agent
    "%s (%s)" % [ Octokit.user_agent, 'githeroes.io' ]
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
