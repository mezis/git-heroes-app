class PullRequestFinder
  TIME_TOO_FAST = 1.hour
  TIME_WHEN_OLD = 2.working.days

  def initialize(organisation:, user:, range:nil)
    @organisation = organisation
    @user = user
    @range = range || (1.working.day.ago .. Time.current)
  end

  def merged_too_quickly
    @merged_too_quickly ||=
    scope.where(
      created_by_id: @user.id,
      merged_at:     @range,
      merge_time:    0..TIME_TOO_FAST,
    ).to_a
  end

  def too_old_other
    @too_old_other ||=
    too_old.where.not(created_by_id: @user.id).to_a
  end

  def too_old_self
    @too_old_self ||=
    too_old.where(created_by_id: @user.id).to_a
  end

  def lacking_comments
    @lacking_comments ||=
    scope.open.where.not(created_by_id: @user.id).where(comments_count: 0).to_a
  end

  private

  def scope
    PullRequest.includes(:created_by, :repository).where(repository_id: repository_ids)
  end

  def too_old
    scope.open.where(
      created_at: 100.years.ago..TIME_WHEN_OLD.ago
    )
  end

  def repository_ids
    @repository_ids ||= @organisation.repositories.enabled.pluck(:id)
  end
end
