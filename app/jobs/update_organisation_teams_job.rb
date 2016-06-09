class UpdateOrganisationTeamsJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    org =     options[:organisation]

    if org.nil?
      Organisation.find_each do |org|
        UpdateOrganisationTeamsJob.perform_later(
          organisation: org,
          actors:       actors | [org],
          parent:       self,
        )
      end
      return
    end

    result =  UpdateOrganisationTeams.call(organisation: org)

    result.updated.each do |team|
      UpdateTeamUsersJob.perform_later(
        team:   team, 
        actors: actors | [org],
        parent: self,
      )
    end
  end
end

