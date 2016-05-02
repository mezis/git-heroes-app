class TeamsController < ApplicationController
  require_authentication!

  def index
    @teams = organisation.teams
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      team = organisation.teams.find(id)
      team.update_attributes!(enabled: update_to)
      render team
    else
      teams = organisation.teams
      teams.each { |t| t.update_attributes!(enabled: update_to) }
      render teams
    end
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def organisation
    @organisation ||= Organisation.find params.require(:organisation_id)
  end
end
