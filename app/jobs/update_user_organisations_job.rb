class UpdateUserOrganisationsJob < BaseJob

  def perform(options = {})
    user = User.find_by_id(options[:actor_id])
    result = UpdateUserOrganisations.call(user: user)

    user.organisations.each do |org|
      UpdateOrganisationUsersJob.perform_later options.merge(organisation_id: org.id)
      UpdateWebhookJob.perform_later options.merge(organisation: org)
    end
  end
end
