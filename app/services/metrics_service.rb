class MetricsService

  attr_reader :organisation, :team

  def initialize(organisation:, team:nil, user:nil)
    @organisation = organisation
    @team = team
    @user = user
  end

  def contributions_over_time
    scope_for(OrganisationUserScore).
      group(:date).sum(:points)
  end

  def contributors_over_time
    scope_for(OrganisationUserScore).
      group(:date).
      distinct.count(:user_id)
  end

  def contribution_per_contributor_over_time
    contributors_by_date = Hash[contributors_over_time]
    contributions_over_time.map do |date,points|
      contributors = contributors_by_date[date]
      contribution = (contributors && contributors > 0) ? (1.0 * points / contributors) : nil
      [date, contribution]
    end
  end

  # TODO: only limit the list if not admin
  def contribution_per_contributor
    data = scope_for(OrganisationUserScore).
      where(date: 4.weeks.ago..Time.now).
      group(:user_id).
      sum(:points).
      sort_by(&:last).reverse.take(5)
    users = User.where(id: data.map(&:first)).to_a.index_by(&:id)
    data.map do |user_id, points|
      [users[user_id].login, points]
    end
  end

  def comments_over_time
    scope_for(Comment).
      group_by_week('comments.created_at', week_start: :mon).
      count.
      map { |time,count| [time.to_date, count] }
  end

  def comments_per_contributor_over_time
    contributors_by_date = Hash[contributors_over_time]
    comments_over_time.map do |date,comments|
      contributors = contributors_by_date[date]
      res = (contributors && contributors > 0) ? (1.0 * comments / contributors) : 0
      [date, res]
    end
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
      date:            1.year.ago..Time.current,
    )
  end

  def _comment_scope
    Comment.joins(:pull_request).
      where(
        pull_requests: { repository_id: repository_ids },
        user_id:       user_ids,
        created_at:    1.year.ago..Time.current,
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
