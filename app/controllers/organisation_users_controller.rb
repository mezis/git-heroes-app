class OrganisationUsersController < ApplicationController
  def index
    @organisation_users = organisation.organisation_users.includes(:user)
  end

  private

  def organisation
    @organisation ||= Organisation.find params.require(:organisation_id)
  end
end
