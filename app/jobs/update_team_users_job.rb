class UpdateTeamUsersJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    team =    options[:team]

    if team.nil?
      Team.includes(:organisation).find_each do |team|
        UpdateTeamUsersJob.perform_later(
          team:   team,
          actors: actors | [team.organisation],
          parent: self,
        )
      end
      return
    end

    UpdateTeamUsers.call(team: team)
  end
end

