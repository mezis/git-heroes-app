class OrganisationsController < ApplicationController
  require_authentication!
  
  before_filter :load_organisation, only: %i[show update]

  def index
    @organisations = current_user.organisations
  end

  def show
    @organisation = current_organisation
    @hottest_pull_requests = leaderboard_service.hottest_pull_requests
    @slowest_pull_requests = leaderboard_service.slowest_pull_requests
    @fastest_pull_requests = leaderboard_service.fastest_pull_requests
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    current_organisation.update_attributes!(enabled: update_to)
    render current_organisation
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def leaderboard_service
    @leaderboard_service ||= LeaderboardService.new(organisation: current_organisation)
  end

  def load_organisation
    current_organisation! Organisation.find_by_name(params.require(:id))
  end
end
