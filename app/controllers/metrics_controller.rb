class MetricsController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def show
    authorize current_organisation
    authorize(params_user || params_team || current_organisation)

    metric_name = params.require(:id)
    unless metrics_service.respond_to?(metric_name)
      raise ActiveRecord::RecordNotFound
    end
    render json: metrics_service.public_send(metric_name)
  end

  private

  def metrics_service
    @metrics_service ||=
      if params_user
        can_compare = policy(current_user).compare?
        UserMetricsService.new(organisation: current_organisation, user: params_user, compare: can_compare)
      else
        MetricsService.new(organisation: current_organisation, team: params_team)
      end
  end

  def params_team
    @params_team ||= params[:team_id] ? current_organisation.teams.find(params[:team_id]) : nil
  end

  def params_user
    @params_user ||= params[:user_id] ? current_organisation.users.find(params[:user_id]) : nil
  end

  def load_organisation
    current_organisation! Organisation.find_by_name params.require(:organisation_id)
  end
end
