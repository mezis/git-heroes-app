class TeamsController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def index
    @teams = organisation_teams
    @dupe_users = compute_dupe_users
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      team = current_organisation.teams.find(id)
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
    current_organisation! Organisation.find params.require(:organisation_id)
  end

  def organisation_teams
    @_organisation_teams ||= current_organisation.teams.includes(:users)
  end

  def compute_dupe_users
    organisation_teams.select(&:enabled).flat_map(&:users).each_with_object({}) { |u,h| h[u] = h.fetch(u,0) + 1 }.select { |u,count| count > 1 }.map(&:first)
  end
end
