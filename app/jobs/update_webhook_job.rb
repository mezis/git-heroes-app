class UpdateWebhookJob < BaseJob
  def perform(options = {})
    org = options[:organisation]
    result = UpdateWebhook.call(organisation: org)
    if result.created || result.updated
      actor = org.users.where.not(github_token: nil).sample
      raise if actor.nil?
      UpdateOrganisationUsersJob.perform_later(
        actor_id: actor.id, 
        organisation_id: org.id)
      # FIXME: we should rather update the *org* repos,
      # but that code doesn't exist yet
      UpdateUserRepositoriesJob.perform_later(actor_id: actor.id)
    end
  end
end
