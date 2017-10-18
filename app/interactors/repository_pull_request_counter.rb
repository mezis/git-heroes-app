class RepositoryPullRequestCounter
  include GithubInteractor

  delegate :repository, to: :context

  def call
    data = client.pull_requests(
      repository.full_name,
      state:     'all',
      sort:      'created',
      direction: 'desc',
      per_page:  1,
    )
    context.number = data.first&.number
  end

  private

  # pick a user to fetch pull requests
  def user
    @user ||= pick_user(repository.public? ? User : repository.users)
  end
  
end
