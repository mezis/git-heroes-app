class UpdateOrganisationUsersJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    user =   options[:user]
    org =    options[:organisation]

    UpdateOrganisationUsers.call(user: user, organisation: org)

    UpdateOrganisationTeamsJob.perform_later(
      organisation: org,
      actors:       actors | [user, org].compact,
      parent:       self,
    )
  end
end
