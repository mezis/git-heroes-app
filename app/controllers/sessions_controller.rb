class SessionsController < ApplicationController
  before_filter :skip_authorization
  before_filter :skip_policy_scope
    
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

    if result.created
      UpdateUserOrganisationsJob.perform_later actor_id: current_user.id
      UpdateUserRepositoriesJob.perform_later  actor_id: current_user.id
    end

    flash[:notice] = result.created ? 'Account created' : 'Welcome back'

    if target = request.env['omniauth.origin'] && target.present?
      redirect_to target
    elsif org = current_user.organisations.first
      redirect_to org
    else
      redirect_to root_path
    end
  end

  def intermission
    if permanent_cookie.intermission_viewed.present?
      redirect_to session_path(origin: request.referer)
    else
      permanent_cookie.intermission_viewed = true
      set_permanent_cookie
    end
  end

  def update
    if params[:act_as]
      authorize :session
      session[:act_as] = params[:act_as]
    else
      session[:act_as] = 'none'
    end
    redirect_to :back, status: 303
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
