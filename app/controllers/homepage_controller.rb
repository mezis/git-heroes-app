class HomepageController < ApplicationController
  before_filter :skip_authorization
  before_filter :skip_policy_scope

  def show
    if current_user
      @jobs = JobStats.where(actor: current_user)
      @organisations = current_user.organisations
    end
  end
end
