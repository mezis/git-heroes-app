class SessionsController < ApplicationController
  def new
    redirect_to '/auth/github'
  end

  def create
    result = FindOrCreateUser.call(auth_hash: request.env['omniauth.auth'])

    if result.success?
      authenticate! result.user

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
