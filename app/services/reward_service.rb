class RewardService

  def initialize(organisation:, date:)
    @organisation = organisation
    @date = date
  end

  def call
    seen_users = Set.new()
    rewards = []
    
    Reward.natures.keys.each do |nature|
      # each of these returns zero or more users
      [send("_users_with_#{nature}")].flatten.map do |u|
        next if u.nil?
        next if seen_users.include?(u)
        rewards << Reward.new(date: @date, organisation: @organisation, user: u, nature: nature)
        seen_users.add(u)
      end
    end

    # save all the things
    Reward.transaction do
      @organisation.rewards.where(date: @date).destroy_all
      rewards.each(&:save!)
    end
  end

  private


  def _users_with_most_points
    @_users_with_most_points ||= scores.sort_by(&:points).reverse.first&.user
  end

  def _users_with_team_most_points
    user_score = scores.index_by(&:user)
    teams.map { |team|
      team.users.
        map { |u| user_score[u] }.
        compact. # some users may not have scores
        sort_by(&:points).reverse.first&.user
    }.compact.uniq
  end

  def _users_with_most_points_twice
    previous = previous_rewards.select { |r| r.most_points? || r.most_points_twice? }.first&.user
    (previous == _users_with_most_points) ? previous : nil
  end

  def _users_with_second_most_points
    scores.sort_by(&:points).reverse.second&.user
  end

  def _users_with_reactivated
    scores.
      select { |s| 
        s.points > 0 &&
        had_points_before.exclude?(s.user) &&
        had_points_before.include?(s.user)
      }.
      sort_by(&:points).
      reverse.
      map(&:user)
  end

  def _users_with_most_comments
    scores.sort_by(&:comment_count).reverse.first&.user
  end

  def _users_with_most_cross_team_comments
    scores.sort_by(&:cross_team_comment_count).reverse.first&.user
  end

  def _users_with_most_pull_requests
    scores.sort_by(&:pull_request_count).reverse.first&.user
  end

  def _users_with_most_other_merges
    scores.sort_by(&:other_merges).reverse.first&.user
  end

  def _users_with_top_newly_active
    scores.
      select { |s| 
        s.points > 0 &&
        had_points_before.exclude?(s.user)
      }.
      sort_by(&:points).
      reverse.
      map(&:user)
  end

  def _users_with_consistent_merge_time
    scores.
      select { |s|
        s.pull_request_count >= 3 &&
        s.pull_request_merge_time > 30.minutes
      }.
      sort_by(&:pull_request_merge_stddev).
      map(&:user).first
  end

  # helpers

  def teams
    @teams ||= @organisation.teams.includes(:users).enabled.to_a
  end

  def scores
    @scores ||= @organisation.scores.includes(:user).where(date: @date).to_a
  end

  def previous_rewards
    @organisation.rewards.includes(:user).where(date: @date - 7)
  end

  # users who had no points recently
  def had_points_recently
    @had_points_recently ||= Set.new(
      User.includes(:scores).
        where(
          organisation_user_scores: {
            organisation_id: @organisation.id,
            date: (@date-14)..(@date-7),
            points: 1..Float::INFINITY,
          }
        ).to_a)
  end

  # users who have contributed at any point until 2 weeks ago.
  def had_points_before
    @had_points_before ||= Set.new(
      User.includes(:scores).
        where(
          organisation_user_scores: {
            organisation_id: @organisation.id,
            date:  100.years.ago.to_date..(@date-8),
            points: 1..Float::INFINITY,
          }
        ).to_a)
  end
end
