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
    if hook.present? && hook.to_hash.deep_merge(DESIRED_DATA) != hook.to_hash
      client.edit_org_hook(organisation.name, hook.id, {}, DESIRED_DATA)
      context.updated = true
    end

    # add if missing
    if hook.nil?
      client.create_org_hook(organisation.name, {}, DESIRED_DATA)
      context.created = true
    end

    # update org timestamp
    organisation.update_attributes! webhook_updated_at: Time.current

  rescue StandardError
    # if something goes wrong, it's safer to assume the hook is absent or broken
    organisation.update_attributes! webhook_updated_at: nil
    raise
  end

  private

  DESIRED_DATA = {
    name:    'web',
    active:  true,
    events:  %w[
      issue_comment
      member
      membership
      pull_request
      pull_request_review_comment
      repository
    ],
    config:  {
      url:           ENV.fetch('HOOK_URL'),
      content_type:  'json',
    },
  }.deep_stringify_keys.deep_freeze

  def user
    # only org admins can do this
    @user ||= pick_user organisation.users.where(organisation_users: { role: OrganisationUser.roles['admin'] })
  end
end
