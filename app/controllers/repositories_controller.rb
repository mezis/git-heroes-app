class RepositoriesController < ApplicationController
  require_authentication!

  before_filter :load_organisation

  def index
    authorize Repository
    authorize current_organisation, :show?
    @repositories = decorate all_repositories.sort_by { |r| r.name.downcase }
  end
  

  def update
    update_to = _parse_boolean params.require(:enabled)
    if id = params[:id]
      repository = all_repositories.find_by_name(id)
      authorize repository
      repository.update_attributes!(enabled: update_to)
      render decorate [repository]
    else
      repositories = all_repositories
      repositories.each do |t| 
        authorize t
        t.update_attributes!(enabled: update_to)
      end
      render decorate repositories
    end
  end

  private

  def decorate(repos)
    RepositoriesDecorator.new(repos)
  end

  def _parse_boolean(x)
    !!(x =~ /^true$/i)
  end

  def all_repositories
    policy_scope current_organisation.repositories.includes(:owner)
  end

  def load_organisation
    current_organisation! Organisation.find_by_name(params.require(:organisation_id))
  end
end
