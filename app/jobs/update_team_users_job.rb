class UpdateTeamUsersJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    team =    options.fetch(:team)

    UpdateTeamUsers.call(team: team)
  end
end

