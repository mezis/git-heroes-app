require 'net/http/persistent'

class GithubClient < Delegator
  def initialize(user)
    @user = user
  end

  def __getobj__
    @client ||= Octokit::Client.new(login: @user.login, password: @user.github_token, middleware: stack)
  end

  private
  
  def stack
    @stack ||= Faraday::Builder.new do |builder|
      builder.use     Octokit::Response::RaiseError
      builder.adapter :net_http_persistent
    end
  end
end
