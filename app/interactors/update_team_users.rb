class UpdateTeamUsers
  include GithubInteractor

  delegate :team, to: :context

  def call
    users = %w[maintainer member].each_with_object({}) do |role,h|
      h[role] = paginate { 
        client.team_members(team.github_id, role: role)
      }.map { |h|
        FindOrCreateUser.call(data: h).record
      }.to_a
    end

    team_users = users.map do |role, users|
      users.map do |u|
        tu = team.team_users.find_or_initialize_by user: u
        tu.role = role
        tu
      end
    end

    team.transaction do
      team_users.flatten.each { |tu| tu.save! if tu.changed? }
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

