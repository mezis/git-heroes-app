class UpdatePullRequest
  include GithubInteractor

  delegate :pull_request, :record, to: :context

  def call
    Rails.logger.info "updating pull request: #{repository.full_name}##{pull_request.github_number}"
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
    @user ||= pick_user repository.users
  end

end