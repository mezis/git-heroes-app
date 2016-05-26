class PersonalStatsService
  attr_reader :range

  def initialize(organisation:, user:, range:nil)
    @organisation = organisation
    @user = user
    @range = range || (1.working.day.ago .. Time.current)
  end

  def activity?
    (comments_written + comments_received + prs_issued + prs_merged) > 0
  end

  # Need daily scores for this
  # def points
  #   @points ||=
  #   OrganisationUserScore.where(
  #     user_id:         @user.id,
  #     organisation_id: @organisation.id,
  #     date:            @range,
  #   ).sum(:points)
  # end

  # def rank
  #   all_points =
  #   OrganisationUserScore.where(
  #     organisation_id: @organisation.id,
  #     date:            @range,
  #   ).group(:user_id).sum 
  # end

  def comments_written
    @comments_written ||=
    Comment.includes(:pull_request).
      where(
        created_at:    @range,
        user_id:       @user.id,
        pull_requests: { repository_id: repository_ids }
      ).count
  end

  def comments_received
    @comments_received ||=
    Comment.includes(:pull_request).
      where(
        created_at:      @range,
        pull_requests: { 
          created_by_id: @user.id,
          repository_id: repository_ids 
        }
      ).where.not(
        user_id:         @user.id
      ).count
  end

  def prs_issued
    @prs_issued ||=
    PullRequest.where(
      created_at:     @range,
      created_by_id:  @user.id,
      repository_id:  repository_ids
    ).count
  end

  def prs_merged
    @prs_merged ||= 
    PullRequest.where(
      merged_at:      @range,
      created_by_id:  @user.id,
      repository_id:  repository_ids
    ).count
  end

  private

  def repository_ids
    @repository_ids ||= @organisation.repositories.enabled.pluck(:id)
  end
  
end
