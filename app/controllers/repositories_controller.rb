class RepositoriesController < ApplicationController
  require_authentication!

  def index
    @repositories = organisation.repositories
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    repository.update_attributes!(enabled: update_to)
    render repository
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def organisation
    @organisation ||= Organisation.includes(:repositories).find(params.require(:organisation_id))
  end

  def repository
    @repository ||= organisation.repositories.find params.require(:id)
  end
end
