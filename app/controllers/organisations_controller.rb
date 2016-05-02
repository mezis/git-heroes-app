class OrganisationsController < ApplicationController
  require_authentication!

  def index
    @organisations = current_user.organisations
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    organisation.update_attributes!(enabled: update_to)
    render organisation
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def organisation
    @organisation ||= Organisation.find params.require(:id)
  end
end
