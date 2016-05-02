class TeamsController < ApplicationController
  require_authentication!

  def index
    @teams = organisation.teams
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    team.update_attributes!(enabled: update_to)
    render team
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def organisation
    @organisation ||= Organisation.find params.require(:organisation_id)
  end

  def team
    @team ||= organisation.teams.find params.require(:id)
  end
end
