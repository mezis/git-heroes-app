module AuthenticationTokenConcern
  extend ActiveSupport::Concern
  include AuthenticationConcern

  def token_authenticate!
    return unless request.method == 'GET'
    return unless string = params[:t]
    return unless token = AuthenticationToken.find(string)
    return unless token.user

    token.decrement!
    authenticate! token.user
    flash[:warning] = render_to_string 'token_auth_alert',
      locals: { token: token },
      layout: false
    redirect_to request.path # without the token parameter
  end

  module ClassMethods
    def allow_token_authentication!(options = {})
      before_filter :token_authenticate!, options
    end
  end
end
