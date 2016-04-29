class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate!(user)
    token = SecureRandom.urlsafe_base64(32)
    user.update_attributes! token: token
    session[:token] = token
    @current_user = user
  end

  def logout!
    @current_user.update_attributes!(token: nil) if @current_user
    reset_session
    @current_user = nil
  end

  helper_method :current_user

  def current_user
    @current_user ||= begin
      return unless token = session[:token]
      User.where(token: token).first
    end
  end
end
