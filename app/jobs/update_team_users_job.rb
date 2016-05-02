class UpdateTeamUsersJob < BaseJob
  def perform(options = {})
    team = Team.find_by_id(options[:team_id])
    UpdateTeamUsers.call(team: team)
  end
end

