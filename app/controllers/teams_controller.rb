class TeamsController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def index
    @teams = policy_scope organisation_teams
    @dupe_users = compute_dupe_users
  end

  def show
    @team = current_organisation.teams.find_by_slug params.require(:id)

    leaderboard_service = LeaderboardService.new(organisation: current_organisation, team: @team)
    @hottest_pull_requests = leaderboard_service.hottest_pull_requests
    @slowest_pull_requests = leaderboard_service.slowest_pull_requests
    @fastest_pull_requests = leaderboard_service.fastest_pull_requests
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      team = current_organisation.teams.find_by_slug(id)
      team.update_attributes!(enabled: update_to)
      to_render = [team]
    else
      organisation_teams.each { |t| t.update_attributes!(enabled: update_to) }
      to_render = organisation_teams
    end
    render partial: 'shared/loner', collection: [{ partial: 'dupe_users', locals: { dupe_users: compute_dupe_users } }, *organisation_teams]
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def load_organisation
    current_organisation! Organisation.find_by_name params.require(:organisation_id)
    authorize current_organisation
  end

  def organisation_teams
    @_organisation_teams ||= current_organisation.teams.includes(:users)
  end

  def compute_dupe_users
    organisation_teams.select(&:enabled).flat_map(&:users).each_with_object({}) { |u,h| h[u] = h.fetch(u,0) + 1 }.select { |u,count| count > 1 }.map(&:first)
  end
end
