class RepositoriesController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def index
    @repositories = decorate all_repositories.sort_by { |r| r.name.downcase }
  end
  

  def update
    # TODO: authorization
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      repository = all_repositories.find(id)
      repository.update_attributes!(enabled: update_to)
      render decorate [repository]
    else
      repositories = all_repositories
      repositories.each { |t| t.update_attributes!(enabled: update_to) }
      render decorate repositories
    end
  end

  private

  def decorate(repos)
    RepositoriesDecorator.new(repos, organisation: current_organisation)
  end

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def all_repositories
    current_organisation.repositories.includes(:owner)
  end

  def load_organisation
    current_organisation! Organisation.includes(:repositories).find(params.require(:organisation_id))
  end
end
