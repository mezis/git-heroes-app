class BackgroundJobsController < ApplicationController
  MAX_JOBS = 5

  def index
    skip_policy_scope

    if params[:organisation_id]
      current_organisation! current_user.organisations.where(id: params[:organisation_id]).first
    end

    @jobs = decorate [
      current_user &&
        JobStats.where(actor: current_user).take(MAX_JOBS).to_a,
      current_organisation &&
        JobStats.where(actor: current_organisation).take(MAX_JOBS).to_a,
    ].flatten.compact.
      sort_by(&:enqueued_at).uniq(&:job_class).take(MAX_JOBS)

    render layout: false
  end
end
