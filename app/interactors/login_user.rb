# Given a Github user hash, and a Github authentication token,
# - create or update the user record,
# - add email if missing,
# - trigger a sync job if created.
class LoginUser
  include GithubInteractor

  delegate :data, :token, :record, to: :context

  def call
    FindOrCreateUser.call(data: data).tap do |result|
      context.record  = result.record
      context.created = result.created
      context.updated = result.updated
    end
    
    record.github_token = token
    if record.changed?
      context.updated = true unless context.created
      record.save!
    end

    UpdateUserEmail.call(user: record).tap do |result|
      context.updated = true if result.updated && !context.created
    end

    if context.created
      InitialSyncJob.perform_later actors: [record], user: record
    end
  end

  protected

  def user
    context.record
  end
end
