module RouterConcern
  extend ActiveSupport::Concern

  def router
    @router ||= Router.new
  end

  private

  class Router
    include ActionDispatch::Routing::UrlFor

    def initialize
      extend Rails.application.routes.url_helpers
    end

    def default_url_options
      { only_path: true }
    end
  end
end

