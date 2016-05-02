module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

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

  def current_user
    @current_user ||= begin
      return unless token = session[:token]
      User.where(token: token).first
    end
  end
  
  module ClassMethods
    def require_authentication!(options = {})
      before_filter(options) do
        redirect_to session_path unless current_user
      end
    end
  end
end
