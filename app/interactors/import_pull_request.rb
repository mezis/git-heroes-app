class ImportPullRequest
  include GithubInteractor

  delegate :repository, :number, to: :context

  def call
    Rails.logger.info "importing pull request: #{repository.full_name}##{number}"
    data = client.pull_request(repository.full_name, number)
    result = FindOrCreatePullRequest.call(repository: repository, data: data)
    context.record  = result.record
    context.updated = result.updated
    context.created = result.created
  rescue Octokit::NotFound
    # when importing, it's okay that some numbers end up "skipped"
  end

  private

  # pick a user to fetch pull requests
  def user
    @user ||= pick_user(repository.public? ? User : repository.users)
  end
end

