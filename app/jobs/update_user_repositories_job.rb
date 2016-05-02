class UpdateUserRepositoriesJob < BaseJob

  def perform(options = {})
    user = User.find_by_id(options[:actor_id])
    result = UpdateUserRepositories.call(user: user)

    user.member_repositories.find_each do |repo|
      UpdateRepositoryPullRequestsJob.perform_later repository_id: repo.id
    end
  end
end
