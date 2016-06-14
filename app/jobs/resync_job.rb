class ResyncJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])


    [
      UpdateOrganisationUsersJob,
      UpdateOrganisationTeamsJob,
      UpdateTeamUsersJob,
      UpdateUserEmailJob,
      UpdateUserOrganisationsJob,
      UpdateUserRepositoriesJob,
    ].each do |job_class|
      job_class.perform_later(
        actors:       actors,
        parent:       self,
      )
    end
  end
end


