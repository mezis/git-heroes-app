module GithubInteractor
  extend ActiveSupport::Concern

  included { include Interactor }

  protected

  def user
    raise NotImplementedError
  end

  # pick a user with enough rate limit left
  def pick_user(scope)
    scope.order(:throttle_left).last
  end

  def client
    @client ||= GithubClient.new(user)
  end

  # pass a block that performs a paginable request
  # to the client
  def paginate
    Enumerator.new { |y|
      yield.each { |h| y << h }
      while uri = client.last_response.rels[:next]&.href
        client.get(uri).each { |h| y << h }
      end
    }.lazy
  end
end
