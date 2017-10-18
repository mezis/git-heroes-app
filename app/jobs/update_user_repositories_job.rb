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

    import_or_update = ->(klass, repo) do
      klass.perform_later(
          repository: repo, 
          actors:     actors | [user, repo.owner],
          parent:     self,
      )
    end

    result.created.each do |repo|
      import_or_update.(ImportRepositoryPullRequestsJob, repo)
    end

    result.updated.each do |repo|
      import_or_update.(UpdateRepositoryPullRequestsJob, repo)
    end
  end

  private

end
