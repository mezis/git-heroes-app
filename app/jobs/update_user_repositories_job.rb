class UpdateUserRepositoriesJob < BaseJob

  def perform(options = {})
    actors =  options.fetch(:actors, [])
    user =    options[:user]

    if user.nil?
      User.where.not(github_token: nil).find_each do |user|
        UpdateUserRepositoriesJob.perform_later(
          user:     user,
          actors:   actors | [user],
          parent:   self,
        )
      end
      return
    end

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
