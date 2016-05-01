require 'net/http/persistent'

class GithubClient
  def initialize(user)
    @user = user
    @last_time = Time.current
  end

  def respond_to_missing?(name, include_private=false)
    client.respond_to?(name, include_private)
  end

  def method_missing(name, *args, &block)
    client.public_send(name, *args, &block).tap do
      if client.last_response && client.last_response.time != @last_time
        UpdateUserRateLimit.new(user: @user, headers: client.last_response.headers).run
        @last_time = client.last_response.time
      end
    end
  end

  private

  def client
    @client ||= Octokit::Client.new(login: @user.login, password: @user.github_token, middleware: stack)
  end
  
  def stack
    @stack ||= Faraday::RackBuilder.new do |builder|
      builder.use     Faraday::HttpCache, store: Rails.cache, instrumenter: ActiveSupport::Notifications
      builder.use     Octokit::Response::RaiseError
      builder.adapter :net_http_persistent
    end
  end
end
