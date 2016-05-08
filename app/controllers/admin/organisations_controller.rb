class Admin::OrganisationsController < ApplicationController
  require_authentication!
  before_filter { authorize :admin }
  before_filter :skip_policy_scope

  def index
    @organisations = Organisation.order(:name).page(params[:page])
  end
end
