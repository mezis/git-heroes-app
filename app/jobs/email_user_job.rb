class EmailUserJob < BaseJob
  def perform(options = {})
    org_user = options.fetch(:organisation_user, nil)
    actors = options.fetch(:actors, [])

    if org_user.nil?
      OrganisationUser.includes(:organisation, user: :settings).find_each do |ou|
        next unless EmailUserService.new(ou).can_email?
        EmailUserJob.perform_later(
          organisation_user:  ou, 
          actors:             actors | [ou.user, ou.organisation],
          parent:             self,
        )
      end
      return
    end

    EmailUserService.new(org_user).deliver
  end
end
