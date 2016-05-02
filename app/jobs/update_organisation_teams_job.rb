class UpdateOrganisationTeamsJob < BaseJob
  def perform(options = {})
    org = Organisation.find_by_id(options[:organisation_id])
    result = UpdateOrganisationTeams.call(organisation: org)

    result.updated.each do |team|
      UpdateTeamUsersJob.perform_later team_id: team.id
    end
  end
end

