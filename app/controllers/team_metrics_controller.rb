class TeamMetricsController < ApplicationController
  require_authentication!

  def show
    authorize team
    respond_to do |format|
      format.csv { render csv: members_list }
      format.json { render json: members_matrix }
    end
  end

  private

  # [
  #   %w[name color],
  #   %w[red   #FF0000],
  #   %w[green #00FF00],
  #   %w[blue  #0000FF],
  # ]
  def members_list
    [%w[name color]] +
    users.map do |user|
      [user.login, colour_for(user)]
    end
  end

  # one row and column per user.
  # this code excludes self comments.
  # [
  #   [2, 1, 1],
  #   [1, 2, 1],
  #   [1, 2, 0],
  # ]
  def members_matrix
    matrix = ([[0] * users.length] * users.length).deep_dup
    counts = Comment.
      joins(:pull_request).
      where(created_at: 4.weeks.ago .. Time.current).
      where(user_id: user_ids, pull_requests: { created_by_id: user_ids }).
      group(:user_id, 'pull_requests.created_by_id').
      count
    counts.each do |(id1,id2),count|
      idx1 = user_index(id1)
      idx2 = user_index(id2)
      next unless idx1 && idx2
      next if idx1 == idx2
      matrix[idx1][idx2] = count
    end
    # binding.pry
    matrix
  end

  def user_index(id)
    @user_index ||= {}.tap do |h|
      users.each_with_index do |u,idx|
        h[u.id] = idx
      end
    end
    @user_index[id]
  end

  def user_ids
    @user_ids ||= users.map(&:id)
  end

  def users
    @users ||= team.users.sort_by { |u| u.login.downcase }
  end

  def colour_for(user)
    '#' + Digest::MD5.hexdigest(user.login)[0,6].upcase
  end

  def team
    @team ||= organisation.teams.find_by_slug params[:id]
  end

  def organisation
    @organisation ||= Organisation.find_by_name params[:organisation_id]
  end
end
