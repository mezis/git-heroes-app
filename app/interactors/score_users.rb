# Score users for the week _starting_ on the date
class ScoreUsers
  include Interactor

  delegate :organisation, :date, to: :context

  def call
    # issued PRs
    PullRequest.includes(:created_by).where(
      repository_id: repository_ids,
      created_at: start_at..end_at
    ).find_each do |pr|
      scores[pr.created_by].points += POINT_RULES.create
    end

    # merged PRs
    PullRequest.includes(:created_by, :merged_by).where(
      repository_id: repository_ids,
      merged_at: start_at..end_at
    ).find_each do |pr|
      if pr.merged_by == pr.created_by
        scores[pr.merged_by].points += POINT_RULES.self_merge
      else
        scores[pr.merged_by].points += POINT_RULES.other_merge
        scores[pr.merged_by].other_merges += 1
      end
      scores[pr.created_by].pull_request_count += 1
      merge_times[pr.created_by] << (pr.merged_at - pr.created_at)
    end

    # comments
    Comment.includes(user: :teams, pull_request: [:repository, created_by: :teams]).where(
      pull_requests: { repository_id: repository_ids },
      created_at: start_at..end_at
    ).find_each do |c|
      if c.user == c.pull_request.created_by
        scores[c.user].points += POINT_RULES.self_comment
        scores[c.user].self_comment_count += 1
      elsif different_teams?(c.user, c.pull_request.created_by)
        scores[c.user].points += POINT_RULES.cross_team_comment
        scores[c.user].cross_team_comment_count += 1
      else
        scores[c.user].points += POINT_RULES.other_comment
        scores[c.user].other_comment_count += 1
      end
      scores[c.user].comment_count += 1
    end

    merge_times.each_pair do |user, times|
      scores[user].pull_request_merge_time = times.median
      scores[user].pull_request_merge_stddev = times.stddev
    end

    OrganisationUserScore.transaction do
      scores.each_pair do |user, score|
        # next if user.nil? # contributions by people no longer in the org
        score.save!
      end
    end
  end

  private

  POINT_RULES = Hashie::Mash.new(
    create:             1,
    self_merge:         2,
    other_merge:        3,
    self_comment:       1,
    other_comment:      2,
    cross_team_comment: 3,
  )

  def different_teams?(u1, u2)
    (u1.teams.select(&:enabled?) & u2.teams.select(&:enabled?)).empty?
  end

  def repository_ids
    @repository_ids ||= organisation.repositories.enabled.pluck(:id)
  end

  def start_at
    @start_at ||= (date || Date.current).beginning_of_week.beginning_of_day
  end

  def end_at
    @end_at ||= start_at + 1.week
  end

  # User -> OrganisationUserScore
  def scores
    @scores ||= Hash.new do |h,user|
      h[user] = OrganisationUserScore.find_or_initialize_by(
        organisation:      organisation,
        user:              user,
        date:              start_at.to_date
      ).tap do |s|
        s.pull_request_count =
        s.points =
        s.comment_count =
        s.self_comment_count =
        s.other_comment_count =
        s.cross_team_comment_count = 0
        s.other_merges = 0
      end
    end
  end

  # User -> numeric array
  def merge_times
    @merge_times ||= Hash.new do |h,user|
      h[user] = [].extend(StatsArray)
    end
  end

  module StatsArray
    def median
      if length.odd?
        self[length/2]
      else
        0.5 * (self[length/2-1] + self[length/2])
      end
    end

    def squares
      map { |x| x**2 }.extend(StatsArray)
    end

    def mean
      1.0 * sum / length
    end

    def stddev
      Math.sqrt(squares.mean - mean**2)
    end
  end
end

