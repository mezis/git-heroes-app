class UpdateUserOrganisationsJob < BaseJob

  def perform(options = {})
    actors =  options.fetch(:actors, [])
    user =    options.fetch(:user)

    result = UpdateUserOrganisations.call(user: user)

    user.organisations.each do |org|
      UpdateWebhookJob.perform_later(
        organisation: org, 
        actors:       actors | [org],
        parent:       self,
      )
      UpdateOrganisationUsersJob.perform_later(
        organisation: org,
        actors:       actors | [org],
        parent:       self,
      )
    end
  end
end
