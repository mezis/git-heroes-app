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
      scores[pr.merged_by].points += 
        (pr.merged_by == pr.created_by) ?
        POINT_RULES.self_merge :
        POINT_RULES.other_merge
      scores[pr.created_by].pull_request_count += 1
      merge_times[pr.created_by] << (pr.merged_at - pr.created_at)
    end

    # comments
    Comment.includes(:user, pull_request: [:created_by, :repository]).where(
      pull_requests: { repository_id: repository_ids },
      created_at: start_at..end_at
    ).find_each do |c|
      scores[c.user].points +=
        (c.user == c.pull_request.created_by) ?
        POINT_RULES.self_comment :
        POINT_RULES.other_comment
      # TODO: comments on other teams
    end

    merge_times.each_pair do |user, times|
      scores[user].pull_request_merge_time = times.median
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
      ).tap do |score|
        score.points = 0
        score.pull_request_count = 0
      end
    end
  end

  # User -> numeric array
  def merge_times
    @merge_times ||= Hash.new do |h,user|
      h[user] = StatsArray.new
    end
  end

  class StatsArray < Array
    def median
      if length.odd?
        self[length/2]
      else
        0.5 * (self[length/2-1] + self[length/2])
      end
    end
  end
end

