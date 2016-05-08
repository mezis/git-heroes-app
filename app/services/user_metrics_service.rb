class UserMetricsService
  attr_reader :organisation, :user

  def initialize(organisation:, team:nil, user:nil)
    @organisation = organisation
    @user = user
    @org_metrics = MetricsService.new(organisation: @organisation)
    @user_metrics = MetricsService.new(organisation: @organisation, user: @user)
  end

  def contributions_over_time
    [{
      name: 'organisation',
      data: @org_metrics.contribution_per_contributor_over_time,
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__)
    }]
  end

  def hour_of_pull_request_created
    [{
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }]
  end

  def hour_of_comment_created
    [{
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }]
  end

  def hour_of_pull_request_marged
    [{
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }]
  end
end
