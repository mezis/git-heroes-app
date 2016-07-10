class UpdateOrganisationUsers
  include GithubInteractor

  delegate :organisation, to: :context

  # Not transactional as there can be a huge number of members
  # in an organisation.
  # Not parallel-safe, but this is run job exclusive jobs.
  def call
    org_users_ids = Set.new
    admin_ids = Set.new
    
    # create new users & memberships
    %w[admin member].each do |role|
      paginate {
        client.organization_members(
          organisation.name, 
          role:     role,
          per_page: 10) 
      }.each do |h|
        user = FindOrCreateUser.call(data: h).record

        ou = organisation.organisation_users.find_or_create_by!(user: user)
        org_users_ids << ou.id
        admin_ids << ou.id if role == 'admin'
      end
    end

    # destroy old memberships, set roles
    organisation.organisation_users.find_each do |ou|
      if org_users_ids.exclude?(ou.id)
        ou.destroy
        next
      end
      ou.role = admin_ids.include?(ou.id) ? 'admin' : 'member'
      ou.save! if ou.changed?
    end
  end

  private

  def user
    context.user || pick_user(organisation.users)
  end
end

