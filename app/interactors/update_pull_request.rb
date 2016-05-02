class UpdatePullRequest
  include Interactor

  delegate :pull_request, :record, to: :context

  def call
    data = client.pull_request(repository.full_name, pull_request.github_number)
    result = FindOrCreatePullRequest.call(repository: repository, data: data)
  end

  private

  def repository
    @repository ||= pull_request.repository
  end

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= repository.users.order(:throttle_left).last
  end

  def client
    @client ||= GithubClient.new(user)
  end
end
