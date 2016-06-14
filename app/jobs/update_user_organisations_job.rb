class UpdateUserOrganisationsJob < BaseJob

  def perform(options = {})
    actors =  options.fetch(:actors, [])
    user =    options[:user]

    if user.nil?
      User.where.not(github_token: nil).find_each do |u|
        UpdateUserOrganisationsJob.perform_later(
          user:   u,
          actors: actors | [u],
          parent: self,
        )
      end
      return
    end

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
