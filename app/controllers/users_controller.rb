class UsersController < ApplicationController
  before_filter :load_organisation

  def index
    @users = current_organisation.users
    
    all_user_ids = Organisation.first.pull_requests.pluck(:created_by_id).uniq
    @former_users = User.where(id: all_user_ids) - @users
  end

  def show
    @user = current_organisation.users.find_by_login params.require(:id)
    @teams = current_organisation.teams.joins(:team_users).where(team_users: { user_id: @user.id })
  end

  private

  def load_organisation
    current_organisation! Organisation.find_by_name(params.require(:organisation_id))
  end
end
