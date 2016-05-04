class OrganisationsController < ApplicationController
  require_authentication!
  
  before_filter :load_organisation, only: %i[show update]

  def index
    @organisations = current_user.organisations
  end

  def show
    @organisation = current_organisation
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    current_organisation.update_attributes!(enabled: update_to)
    render current_organisation
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def load_organisation
    current_organisation! Organisation.find(params.require(:id))
  end
end
