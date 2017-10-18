class UpdateRepositoryPullRequests
  include GithubInteractor

  delegate :repository, :records, to: :context

  def call
    context.record_ids = Set.new

    if user.nil?
      Rails.logger.warn "cannot update #{repository.full_name}: no member user"
      return
    end

    PullRequestIterator.new(user: user, repository: repository).each do |hash|
      result = FindOrCreatePullRequest.call(repository: repository, data: hash)
      context.record_ids << result.record.id if result.created || result.updated
    end
  end

  private

  # pick a user to fetch pull requests
  def user
    @user ||= pick_user(repository.public? ? User : repository.users)
  end
end
