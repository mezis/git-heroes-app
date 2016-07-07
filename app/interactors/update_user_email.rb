# Update a user's email address
class UpdateUserEmail
  include GithubInteractor

  delegate :user, to: :context

  def call
    raise "no login token for @#{user.login}" unless user.github_token

    all_emails = client.emails

    user.email ||= all_emails.find(&:primary)&.email
    if user.changed?
      user.save!
      context.updated = true
    end

    user.settings.emails = all_emails.map(&:email)
    if user.settings.changed?
      user.settings.save!
      context.updated = true
    end
  end
end
