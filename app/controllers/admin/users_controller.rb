class Admin::UsersController < ApplicationController
  require_authentication!
  before_filter { authorize :admin }
  before_filter :skip_policy_scope

  def index
    @users = User.order('LOWER(login)').page(params[:page]).per(100)
  end
end
