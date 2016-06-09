class InitialSyncJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    user = options.fetch(:user)

    UpdateUserOrganisationsJob.perform_later(
      user:   user,
      actors: actors | [user],
      parent: self,
    )
    UpdateUserRepositoriesJob.perform_later(
      user:   user,
      actors: actors | [user],
      parent: self,
    )
  end
end   
