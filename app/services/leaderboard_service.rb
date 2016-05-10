class LeaderboardService
  attr_reader :organisation

  def initialize(organisation:, team:nil, start_date:nil, end_date:nil)
    @organisation = organisation
    @team = team
    @end_date = end_date || Time.current
    @start_date = start_date || (@end_date - 4.weeks)
  end

  def hottest_pull_requests
    cached(__method__) { pull_request_scope.order(comments_count: :DESC).limit(5) }
  end

  def slowest_pull_requests
    cached(__method__) do
      pull_request_scope.with_status(:open, :merged).
        order(%{
          COALESCE(merge_time, 
            EXTRACT(EPOCH FROM NOW()) - EXTRACT(EPOCH FROM created_at)
          ) DESC}).
        limit(5) 
    end
  end

  def fastest_pull_requests
    cached(__method__) { pull_request_scope.merged.order(merge_time: :ASC).limit(5) }
  end

  private

  def cached(label)
    ids = Rails.cache.fetch("#{self.class.name.underscore}/#{label}/org:#{@organisation.id}/team:#{@team&.id}", expires_in: 1.day) do
      yield.map(&:id)
    end
    return [] unless ids.any?
    records = pull_request_includes.find(*ids).index_by(&:id)
    ids.map { |id| records[id] }
  end

  def pull_request_includes
    PullRequest.includes(:created_by, repository: :owner)
  end

  def pull_request_scope
    scope = PullRequest.
      where(
        repository_id: repository_ids,
        created_at: @start_date..@end_date)
    scope = scope.where(created_by_id: @team.users.pluck(:id)) if @team
    scope
  end

  def repository_ids
    @organisation.repositories.enabled.pluck(:id)
  end

end
