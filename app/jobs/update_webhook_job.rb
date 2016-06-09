class UpdateWebhookJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    org =     options[:organisation]

    if org.nil?
      Organisation.find_each do |org|
        UpdateWebhookJob.perform_later organisation: org, actors: actors | [org]
      end
      return
    end

    result = UpdateWebhook.call(organisation: org)

    if result.created || result.updated
      user = org.users.where.not(github_token: nil).sample
      raise 'no elibigible user' if user.nil?

      UpdateOrganisationUsersJob.perform_later(
        user:         user,
        organisation: org,
        actors:       actors | [org],
        parent:       self,
      )
      # FIXME: we should rather update the *org* repos,
      # but that code doesn't exist yet
      UpdateUserRepositoriesJob.perform_later(
        user:         user,
        actors:       actors | [user],
        parent:       self,
      )
    end
  end
end
