class MetricsController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def show
    metric_name = params.require(:id)
    method_name = :"_#{metric_name}"
    unless respond_to?(method_name, true)
      raise ActiveRecord::RecordNotFound
    end
    render json: send(method_name)
  end

  private

  def _contributions_over_time
    OrganisationUserScore.group(:date).sum(:points)
  end

  def _contributors_over_time
    OrganisationUserScore.group(:date).distinct.count(:organisation_user_id)
  end

  def _contribution_per_contributor_over_time
    contributors_by_date = Hash[_contributors_over_time]
    _contributions_over_time.map do |date,points|
      contributors = contributors_by_date[date]
      contribution = (contributors && contributors > 0) ? (1.0 * points / contributors) : nil
      [date, contribution]
    end
  end

  def _contribution_per_contributor
    data = OrganisationUserScore.
      where(date: 4.weeks.ago..Time.now).
      group(:organisation_user_id).
      sum(:points).
      sort_by(&:last).reverse
    org_users = OrganisationUser.includes(:user).where(id: data.map(&:first)).to_a.index_by(&:id)
    data.map do |org_user_id, points|
      [org_users[org_user_id].user.login, points]
    end
  end

  def _comments_over_time
    Comment.joins(:pull_request).
      where(pull_requests: { repository_id: repository_ids }).
      group_by_week('comments.created_at', week_start: :mon).
      count.
      map { |time,count| [time.to_date, count] }
  end

  def _comments_per_contributor_over_time
    contributors_by_date = Hash[_contributors_over_time]
    _comments_over_time.map do |date,comments|
      contributors = contributors_by_date[date]
      res = (contributors && contributors > 0) ? (1.0 * comments / contributors) : 0
      [date, res]
    end
  end

  def _hour_of_pull_request_created
    PullRequest.where(repository_id: repository_ids).
      group_by_hour_of_day(:created_at).
      count
  end

  def _hour_of_comment_created
    Comment.joins(:pull_request).
      where(pull_requests: { repository_id: repository_ids }).
      group_by_hour_of_day('comments.created_at').
      count
  end

  def _hour_of_pull_request_marged
    PullRequest.where(repository_id: repository_ids).
      group_by_hour_of_day(:merged_at).
      count
  end

  def repository_ids
    current_organisation.repositories.enabled.pluck(:id)
  end

  def load_organisation
    current_organisation! Organisation.find params.require(:organisation_id)
  end
end
