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

    options = {
        repository: repo.record, 
        actors:     actors | [user, repo.owner],
        parent:     self,
    }

    result.created.each do |repo|
      ImportRepositoryPullRequestsJob.perform_later(options.merge(repository: repo))
    end

    result.updated.each do |repo|
      UpdateRepositoryPullRequestsJob.perform_later(options.merge(repository: repo))
    end
  end

  private

  def _import_or_update(klass, repo)
    klass.perform_later(
        repository: repo, 
        actors:     actors | [user, repo.owner],
        parent:     self,
    )
  end
end
