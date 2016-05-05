class LeaderboardService
  attr_reader :organisation

  def initialize(organisation:, team:nil, start_date:nil, end_date:nil)
    @organisation = organisation
    @team = team
    @end_date = end_date || Time.current
    @start_date = start_date || (@end_date - 4.weeks)
  end

  def hottest_pull_requests
    pull_request_scope.order(comments_count: :DESC).limit(5)
  end

  def slowest_pull_requests
    pull_request_scope.with_status(:open, :merged).order(merge_time: :DESC).limit(5)
  end

  def fastest_pull_requests
    pull_request_scope.merged.order(merge_time: :ASC).limit(5)
  end

  private

  def pull_request_scope
    PullRequest.
      includes(repository: :owner).
      where(
        repository_id: repository_ids,
        created_at: @start_date..@end_date)
  end

  def repository_ids
    @organisation.repositories.enabled.pluck(:id)
  end

end
