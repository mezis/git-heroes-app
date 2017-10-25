RSpec.configure do |config|
  module Helpers
    def log_in!(user)
      request.session[:token] = user.token
    end
  end
  config.include Helpers, type: :controller
end
