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

    if result.success?
      authenticate! result.record

      if result.created
        flash[:notice] = 'Account created'
      else
        flash[:notice] = 'Welcome back'
      end
    end

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
