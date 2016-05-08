class ApplicationController < ActionController::Base
  include AuthenticationConcern
  include CurrentOrganisationConcern
  include Pundit
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from(Pundit::NotAuthorizedError) do
    render '403', status: 403
  end
end
