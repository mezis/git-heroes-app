class OrganisationUserDecorator < SimpleDelegator
  def initialize(org_user)
    @organisation = org_user.organisation
    @user = org_user.user
    super @user
  end

  def teams
    @teams ||=
      @organisation.teams.joins(:team_users).where(team_users: { user_id: @user.id })
  end

  def recent_pull_requests
    @recent_pull_requests ||= PullRequest.
      includes(:created_by, :repository).
      where(
        created_by_id: @user.id,
        repository_id: repository_ids,
      ).
      order(github_updated_at: :DESC).
      limit(5)
  end

  def recent_comments
    @recent_comments ||= [].tap do |ary|
      # pull 50 recent comments, hope 5 are on distinct PRs
      seen_pr_ids = []
      Comment.
      includes(:user, pull_request: [:created_by, :repository]).
      where.not(pull_requests: { created_by_id: @user.id }).
      where(
        user_id: @user.id,
        pull_requests: { repository_id: repository_ids },
      ).order(created_at: :DESC).
      limit(50).each do |comment|
        next if seen_pr_ids.include? comment.pull_request_id
        ary << comment
        break if ary.length >= 5
      end
    end
  end

  private

  def repository_ids
    @repository_ids ||= @organisation.repositories.pluck(:id)
  end
end
