class UpdateOrganisationUsersJob < BaseJob
  def perform(options = {})
    user = User.find_by_id(options[:user_id])
    org = Organisation.find_by_id(options[:organisation_id])
    result = UpdateOrganisationUsers.call(user: user, organisation: org)
  end
end
