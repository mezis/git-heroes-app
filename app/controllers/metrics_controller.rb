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
    data = metrics_service.public_send(metric_name)
    respond_to do |format|
      format.csv  { render csv: data }
      format.json { render json: data }
    end
  end

  private

  def metrics_service
    @metrics_service ||= begin
      options = {
        organisation: current_organisation,
        start_at:     params_start_at,
        end_at:       params_end_at,
      }
      if params_user
        can_compare = policy(current_user).compare?
        UserMetricsService.new options.merge(user: params_user, compare: can_compare)
      else
        MetricsService.new options.merge(team: params_team)
      end
    end
  end

  def params_team
    @params_team ||= params[:team_id] ? current_organisation.teams.find(params[:team_id]) : nil
  end

  def params_user
    @params_user ||= params[:user_id] ? current_organisation.users.find(params[:user_id]) : nil
  end

  def params_start_at
    params[:start_at] ? Time.at(params[:start_at].to_i) : nil
  end

  def params_end_at
    params[:end_at] ? Time.at(params[:end_at].to_i) : nil
  end

  def load_organisation
    current_organisation! Organisation.find_by_name params.require(:organisation_id)
  end
end
