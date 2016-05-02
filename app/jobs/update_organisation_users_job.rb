class UpdateOrganisationUsersJob < BaseJob
  def perform(options = {})
    user = User.find_by_id(options[:actor_id])
    org = Organisation.find_by_id(options[:organisation_id])
    UpdateOrganisationUsers.call(user: user, organisation: org)

    UpdateOrganisationTeamsJob.perform_later organisation_id: org.id
  end
end
