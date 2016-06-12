# Update a user's email address
class UpdateUserEmail
  include GithubInteractor

  delegate :user, to: :context

  def call
    raise "no login token for @#{user.login}" unless user.github_token

    user.email ||= client.emails.find(&:primary)&.email
    if user.changed?
      user.save!
      context.updated = true
    end
  end
end
