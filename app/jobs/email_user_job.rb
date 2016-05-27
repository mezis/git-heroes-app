class EmailUserJob < BaseJob
  def perform(options = {})
    org_user = options.fetch(:organisation_user, nil)

    if org_user.nil?
      OrganisationUser.includes(user: :settings).find_each do |ou|
        next unless EmailUserService.new(ou).can_email?
        EmailUserJob.perform_later(organisation_user: ou)
      end
    else
      EmailUserService.new(org_user).deliver
    end
  end
end
