class SessionsController < ApplicationController
  def callback
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

    UpdateUserOrganisationsJob.perform_later actor_id: current_user.id
    UpdateUserRepositoriesJob.perform_later  actor_id: current_user.id

    flash[:notice] = result.created ? 'Account created' : 'Welcome back'

    target = request.env['omniauth.origin']
    target = root_path if target.blank?
    redirect_to target
  end

  def destroy
    logout!
    flash[:notice] = 'Sorry to see you go'
    redirect_to root_path
  end

  def failure
    flash[:alert] = 'Authentication failed'
    redirect_to root_url
  end
end
