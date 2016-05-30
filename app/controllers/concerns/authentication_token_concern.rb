module AuthenticationTokenConcern
  extend ActiveSupport::Concern
  include AuthenticationConcern

  def token_authenticate!(string)
    return unless token = AuthenticationToken.find_by(token: string)
    return unless token.user
    authenticate! token.user
    token.decrement!
    flash.now[:warning] = render_to_string 'token_auth_alert',
      locals: { token: token },
      layout: false
  end

  module ClassMethods
    def allow_token_authentication!(options = {})
      before_filter(options) do
        if t = params[:t]
          token_authenticate!(t)
        end
      end
    end
  end
end
