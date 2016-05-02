class RepositoriesController < ApplicationController
  require_authentication!

  def index
    @repositories = organisation.repositories
  end

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      repository = organisation.repositories.find(id)
      repository.update_attributes!(enabled: update_to)
      render repository
    else
      repositories = organisation.repositories
      repositories.each { |t| t.update_attributes!(enabled: update_to) }
      render repositories
    end
  end

  private

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def organisation
    @organisation ||= Organisation.includes(:repositories).find(params.require(:organisation_id))
  end
end
