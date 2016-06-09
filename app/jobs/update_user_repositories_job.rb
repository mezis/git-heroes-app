class UpdateUserRepositoriesJob < BaseJob

  def perform(options = {})
    actors =  options.fetch(:actors, [])
    user =    options.fetch(:user)

    result = UpdateUserRepositories.call(user: user)

    user.member_repositories.find_each do |repo|
      UpdateRepositoryPullRequestsJob.perform_later(
        repository: repo, 
        actors:     actors | [user, repo.owner],
        parent:     self,
      )
    end
  end
end
