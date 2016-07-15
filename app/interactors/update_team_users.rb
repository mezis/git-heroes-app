class UpdateTeamUsers
  include GithubInteractor

  delegate :team, to: :context

  # Not transactional as there can be a huge number of members
  # in a team.
  # Not parallel-safe, but this is run job exclusive jobs.
  def call
    team_user_ids = Set.new
    maintainer_ids = Set.new

    # create new users & memberships
    %w[maintainer member].each do |role|
      paginate { 
        client.team_members(team.github_id, role: role, per_page: 10)
      }.each do |d|
        user = FindOrCreateUser.call(data: d).record
        tu = team.team_users.find_or_create_by!(user: user)
        team_user_ids << tu.id
        maintainer_ids << tu.id if role == 'maintainer'
      end
    end

    team.team_users.find_each do |tu|
      if team_user_ids.exclude?(tu.id)
        tu.destroy
        next
      end

      tu.role = maintainer_ids.include?(tu.id) ? 'maintainer' : 'member'
      tu.save! if tu.changed?
    end
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user team.organisation.users
  end
end

