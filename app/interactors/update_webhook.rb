class UpdateWebhook
  include GithubInteractor

  delegate :organisation, to: :context

  def call
    if user.nil?
      Rails.logger.warn "No admin for organisation #{organisation.name}"
      return
    end

    # check org hooks. always grabbing the first one as an OAuth app can only
    # see hooks it created
    hook = client.org_hooks(organisation.name).first
    
    # update if broken
    if hook.present? && hook.to_hash.deep_merge(desired_data) != hook.to_hash
      client.edit_org_hook(organisation.name, hook.id, {}, desired_data)
      context.updated = true
    end

    # add if missing
    if hook.nil?
      client.create_org_hook(organisation.name, {}, desired_data)
      context.created = true
    end

    # update org timestamp
    organisation.update_attributes! webhook_updated_at: Time.current
  end

  private

  def desired_data
    {
      name:    'web',
      active:  true,
      events:  %w[issue_comment member membership pull_request pull_request_review_comment repository],
      config:  {
        url:           ENV.fetch('HOOK_URL'),
        content_type:  'json',
      },
    }
  end

  def user
    # only org admins can do this
    @user ||= pick_user organisation.users.where(organisation_users: { role: OrganisationUser.roles['admin'] })
  end
end
