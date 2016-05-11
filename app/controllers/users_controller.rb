class UsersController < ApplicationController
  before_filter :load_organisation, only: %i[index show]

  def index
    authorize current_organisation
    @users = policy_scope current_organisation.users
    
    all_user_ids = current_organisation.pull_requests.pluck(:created_by_id).uniq
    @former_users = User.where(id: all_user_ids) - @users
  end

  def show
    @user = load_user
    load_organisation if params[:organisation_id]
    authorize @user

    @teams = current_organisation.teams.joins(:team_users).where(team_users: { user_id: @user.id })

    repository_ids = current_organisation.repositories.pluck(:id)

    @recent_pull_requests = PullRequest.
      includes(:created_by, :repository).
      where(
        created_by_id: @user.id,
        repository_id: repository_ids,
      ).order(github_updated_at: :DESC).limit(5)
    
    # pull 20 recent comments, hope 5 are on distinct PRs
    @recent_comments = [].tap do |ary|
      seen_pr_ids = []
      Comment.
      includes(:user, pull_request: [:created_by, :repository]).
      where.not(pull_requests: { created_by_id: @user.id }).
      where(
        user_id: @user.id,
        pull_requests: { repository_id: repository_ids },
      ).order(created_at: :DESC).
      limit(50).each do |comment|
        next if seen_pr_ids.include? comment.pull_request_id
        ary << comment
        break if ary.length >= 5
      end
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
    current_organisation! Organisation.find_by_name(params[:organisation_id])
  end
end
