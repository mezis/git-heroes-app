class OrganisationUsersController < ApplicationController
  before_filter :load_organisation

  def index
    @organisation_users = current_organisation.organisation_users.includes(:user)
  end

  private

  def load_organisation
    current_organisation! Organisation.find(params.require(:organisation_id))
  end
end
