class UpdateUserOrganisationsJob < BaseJob

  def perform(options = {})
    user = User.find_by_id(options[:actor_id])
    result = UpdateUserOrganisations.call(user: user)
  
    if result.failure?
      return
    end

    user.organisations.each do |org|
      UpdateOrganisationUsersJob.perform_later options.merge(organisation_id: org.id)
    end
  end
end
