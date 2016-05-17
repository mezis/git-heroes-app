class UserMetricsService
  attr_reader :organisation, :user

  def initialize(organisation:, team:nil, user:nil, compare: false)
    @organisation = organisation
    @user = user
    @org_metrics = MetricsService.new(organisation: @organisation)
    @user_metrics = MetricsService.new(organisation: @organisation, user: @user)
    @compare = compare
  end

  def contributions_over_time
    [compare? && {
      name: 'organisation',
      data: @org_metrics.contribution_per_contributor_over_time,
    },
    {
      name: 'user',
      data:  @user_metrics.public_send(__method__)
    }].compact
  end

  def hour_of_pull_request_created
    [compare? && {
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }].compact
  end

  def hour_of_comment_created
    [compare? && {
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }].compact
  end

  def hour_of_pull_request_marged
    [compare? && {
      name: 'organisation',
      data: @org_metrics.public_send(__method__),
    }, {
      name: 'user',
      data:  @user_metrics.public_send(__method__),
    }].compact
  end

  private

  def compare?
    @compare || nil
  end
end
