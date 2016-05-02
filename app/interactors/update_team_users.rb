class UpdateTeamUsers
  include GithubInteractor

  delegate :team, to: :context

  def call
    team.users = paginate {
      client.team_members(team.github_id)
    }.map { |hash|
      FindOrCreateUser.call(data: hash).record
    }.to_a
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user team.organisation.users
  end
end

