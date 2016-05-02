class UpdateOrganisationTeams
  include GithubInteractor

  delegate :organisation, :updated, to: :context

  def call
    context.updated = []
    organisation.teams = paginate {
      client.organization_teams(organisation.name) 
    }.map { |hash|
      result = FindOrCreateTeam.call(organisation: organisation, data: hash)
      context.updated << result.record if result.created || result.changed
      result.record
    }.to_a
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user organisation.users
  end
end


