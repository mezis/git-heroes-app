class UpdateTeamUsers
  include GithubInteractor

  delegate :team, to: :context

  def call
    # team users may appear in multiple Github role queries
    users = %w[maintainer member].each_with_object({}) do |role,h|
      paginate { 
        client.team_members(team.github_id, role: role)
      }.map { |d|
        user = FindOrCreateUser.call(data: d).record
        h[user] ||= role
      }.to_a
    end

    team_users = users.map do |u, role|
      tu = team.team_users.find_or_initialize_by user: u
      tu.role = role
      tu
    end

    team.transaction do
      team_users.select(&:changed?).each(&:save!)
      team.team_users = team_users.flatten
    end
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user team.organisation.users
  end
end

