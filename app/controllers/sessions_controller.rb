class SessionsController < ApplicationController
  def new
    redirect_to '/auth/github'
  end

  def create
    auth_hash = request.env['omniauth.auth']
    result = FindOrCreateUser.call(
      data:    auth_hash.extra.raw_info,
      token:  auth_hash.credentials.token,
    )

    unless result.success?
      flash[:alert] = 'Oh now! Somehow we could not log you in.'
      redirect_to root_path
      return
    end
    authenticate! result.record

    UpdateUserOrganisationsJob.perform_later actor_id: current_user.id, user_id: current_user.id
    UpdateUserRepositoriesJob.perform_later  actor_id: current_user.id, user_id: current_user.id

    flash[:notice] = result.created ? 'Account created' : 'Welcome back'

    redirect_to root_path
  end

  def destroy
    logout!
    flash[:notice] = 'Sorry to see you go'
    redirect_to root_path
  end

  def abort
    flash[:alert] = 'Authentication failed'
    redirect_to root_url
  end
end
