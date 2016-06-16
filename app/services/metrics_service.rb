class MetricsService
  include RouterConcern

  attr_reader :organisation, :team

  def initialize(organisation:, team:nil, user:nil, start_at:nil, end_at:nil)
    @organisation = organisation
    @team = team
    @user = user
    
    end_at   ||= Time.current.beginning_of_week
    start_at ||= end_at - 1.year
    @time_range = start_at .. end_at
  end

  def contributions_over_time
    scope_for(OrganisationUserScore).
      group(:date).
      order(:date).
      sum(:points).
      reverse_merge(date: :points)
  end

  def contributors_over_time
    scope_for(OrganisationUserScore).
      group(:date).
      order(:date).
      distinct.count(:user_id).
      reverse_merge(date: :count)
  end

  def contribution_per_contributor_over_time
    contributors_over_time.tap(&:shift).
    merge(contributions_over_time.tap(&:shift)) { |date,count,points|
      (count && count > 0) ? (1.0 * points / count) : nil
    }.reverse_merge(date: :points)
  end

  # TODO: only limit the list if not admin
  def contribution_per_contributor
    data = scope_for(OrganisationUserScore).
      where(date: @time_range).
      group(:user_id).
      sum(:points).
      sort_by(&:last).reverse.take(5)
    users = User.where(id: data.map(&:first)).to_a.index_by(&:id)
    data.each_with_object([%w[user points url]]) do |(user_id, points), a|
      a << [users[user_id].login, points, router.url_for([@organisation, users[user_id]])]
    end
  end

  def comments_over_time
    scope_for(Comment).
      group_by_week('comments.created_at', week_start: :mon).
      count.
      each_with_object({}) { |(time,count),h|
        h[time.to_date] = count
      }.reverse_merge(date: 'comments')
  end

  def comments_per_contributor_over_time
    comments_over_time.tap(&:shift).
    merge(contributors_over_time.tap(&:shift)) { |date,comments,count|
      (count && count > 0) ? (1.0 * comments / count) : nil
    }.reverse_merge(date: 'comments per contributor')
  end

  def hour_of_pull_request_created
    scope_for(PullRequest).
      group_by_hour_of_day(:created_at).
      count
  end

  def hour_of_comment_created
    scope_for(Comment).
      group_by_hour_of_day('comments.created_at').
      count
  end

  def hour_of_pull_request_marged
    scope_for(PullRequest).
      group_by_hour_of_day(:merged_at).
      count
  end

  private

  def scope_for(model)
    send "_#{model.name.underscore}_scope"
  end

  def _organisation_user_score_scope
    OrganisationUserScore.where(
      organisation_id: organisation.id,
      user_id:         user_ids,
      date:            @time_range,
    )
  end

  def _comment_scope
    Comment.joins(:pull_request).
      where(
        pull_requests: { repository_id: repository_ids },
        user_id:       user_ids,
        created_at:    @time_range,
    )
  end


  def _pull_request_scope
    PullRequest.
      where(repository_id: repository_ids).
      where(created_by_id: user_ids)
  end

  def repository_ids
    organisation.repositories.enabled.pluck(:id)
  end

  def user_ids
    @user_ids ||=
      if @team
        @team.users.pluck(:id)
      elsif @user
        [@user.id]
      else
        User.joins(:teams).where(teams: { id: organisation.teams.enabled.pluck(:id) }).pluck(:id)
      end
  end
end
