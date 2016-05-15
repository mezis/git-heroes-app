class TeamMetricsController < ApplicationController
  require_authentication!

  def show
    authorize(team || organisation)
    respond_to do |format|
      format.csv { render csv: members_list }
      format.json { render json: team ? members_matrix : teams_matrix }
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
    if team
      users.map do |user|
        [user.login, colour_for(user.login)]
      end
    else
      teams.map do |team|
        [team.name, colour_for(team.name)]
      end
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
    each_user_pair do |id1,id2,count|
      idx1 = user_index(id1)
      idx2 = user_index(id2)
      next unless idx1 && idx2
      next if idx1 == idx2
      matrix[idx1][idx2] = count
    end
    matrix
  end

  def teams_matrix
    matrix = ([[0] * teams.length] * teams.length).deep_dup
    each_user_pair do |id1,id2,count|
      idx1 = team_index(id1)
      idx2 = team_index(id2)
      next unless idx1 && idx2
      # next if idx1 == idx2
      matrix[idx1][idx2] += count
    end
    matrix
  end

  # FIXME: also filter by repository (PRs could be outside the org)
  def each_user_pair
    counts = Comment.
      joins(:pull_request).
      where(created_at: 4.weeks.ago .. Time.current).
      where(user_id: user_ids, pull_requests: { created_by_id: user_ids }).
      group(:user_id, 'pull_requests.created_by_id').
      count
    counts.each do |(id1,id2),count|
      yield id1, id2, count
    end
  end

  def user_index(id)
    @user_index ||= {}.tap do |h|
      users.each_with_index do |u,idx|
        h[u.id] = idx
      end
    end
    @user_index[id]
  end

  def team_index(user_id)
    @team_index ||= {}.tap do |h|
      teams.each_with_index do |t,idx|
        t.users.each do |u|
          h[u.id] = idx
        end
      end
    end
    @team_index[user_id]
  end

  def user_ids
    @user_ids ||= users.map(&:id)
  end

  def users
    @users ||= (team || organisation).users.sort_by { |u| u.login.downcase }
  end

  def teams
    @teams ||= organisation.teams.enabled.includes(:users).sort_by { |t| t.name.downcase }
  end

  def colour_for(string)
    angle = 360 * Digest::MD5.hexdigest(string)[0,3].to_i(16) / (16**3)
    "hsl(#{angle}, 75%, 50%)"
  end

  def team
    @team ||= organisation.teams.find_by_slug params[:id]
  end

  def organisation
    @organisation ||= Organisation.find_by_name params[:organisation_id]
  end
end
