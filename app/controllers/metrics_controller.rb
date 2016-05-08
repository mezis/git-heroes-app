class MetricsController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def show
    metric_name = params.require(:id)
    unless metrics_service.respond_to?(metric_name)
      raise ActiveRecord::RecordNotFound
    end
    render json: metrics_service.public_send(metric_name)
  end

  private

  def metrics_service
    @metrics_service ||= MetricsService.new(organisation: current_organisation, team: current_team)
  end

  def current_team
    @current_team ||= params[:team_id] ? current_organisation.teams.find_by_name(params[:team_id]) : nil
  end

  def load_organisation
    current_organisation! Organisation.find_by_name params.require(:organisation_id)
    authorize current_organisation
  end
end
