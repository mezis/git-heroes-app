module GithubInteractor
  extend ActiveSupport::Concern

  included { include Interactor }

  protected

  def user
    raise NotImplementedError
  end

  # pick a user with enough rate limit left
  def pick_user(scope)
    scope.where.not(github_token: nil).order(:throttle_left).last
  end

  def client
    @client ||= GithubClient.new(user)
  end

  # pass a block that performs a paginable request
  # to the client
  def paginate(&block)
    client.paginate(&block)
  end
end
