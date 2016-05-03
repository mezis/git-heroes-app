module CurrentOrganisationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_organisation
  end

  def current_organisation!(org)
    @_current_organisation = org
  end

  def current_organisation
    @_current_organisation
  end
end
