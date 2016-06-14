class UpdateOrganisationUsersJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    user =   options[:user]
    org =    options[:organisation]

    if org.nil?
      Organisation.find_each do |org|
        UpdateOrganisationUsersJob.perform_later(
          organisation:   org,
          actors:         actors | [org],
          parent:         self,
        )
      end
      return
    end

    # need to pick a valid user
    user ||= org.users.where.not(github_token: nil).sample

    UpdateOrganisationUsers.call(user: user, organisation: org)

    UpdateOrganisationTeamsJob.perform_later(
      organisation: org,
      actors:       actors | [user, org].compact,
      parent:       self,
    )
  end
end
