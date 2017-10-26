RSpec.configure do |config|
  module Helpers
    def log_in!(user)
      request.session[:token] = user.token
    end

    def csv_data
      CSV.parse(response.body, headers: true)
    end

    def json_data
      JSON.parse(response.body)
    end
  end
  config.include Helpers, type: :controller
end