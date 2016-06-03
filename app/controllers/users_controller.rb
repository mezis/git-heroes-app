class UsersController < ApplicationController
  require_authentication!

  before_filter :load_organisation, only: %i[index show]

  def index
    authorize User
    authorize current_organisation, :show?
    @users = policy_scope current_organisation.users
    
    all_user_ids = current_organisation.pull_requests.pluck(:created_by_id).uniq
    @former_users = User.where(id: all_user_ids) - @users
  end

  def show
    @user = load_user
    load_organisation if params[:organisation_id]
    authorize @user

    if policy(@user).update?
      @user_settings = @user.settings
      # unfortuntely routing goes to fuck if the record is unsaved
      @user_settings.save! unless @user_settings.persisted?
    end

    if current_organisation
      org_user = OrganisationUser.find_by(user_id: @user.id, organisation_id: current_organisation.id)
      @user = decorate org_user
      @teams = @user.teams
      @recent_pull_requests = @user.recent_pull_requests
      @recent_comments = @user.recent_comments
    end
  end

  def update
    @user = load_user
    authorize @user

    data = params.require(:user).permit(:email)

    if @user.update_attributes(data)
      flash[:notice] = 'Thanks, your data was updated!'
      current_user.reload if current_user == @user
    else
      flash[:alert] = "Sorry, we did not quite get that. #{@user.errors.full_messages.to_sentence}."
    end

    if request.xhr?
      render partial: 'flashes'
      flash.clear
    else
      redirect_to :back
    end
  end

  private

  def load_user
    User.find_by_login(params.require(:id))
  end

  def load_organisation
    current_organisation! Organisation.find_by(name: params[:organisation_id])
  end
end
