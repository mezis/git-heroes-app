class UpdateOrganisationUsers
  include GithubInteractor

  delegate :organisation, to: :context

  def call
    users = %w[admin member].each_with_object({}) do |role,h|
      h[role] = all_members(role: role).map { |h| FindOrCreateUser.call(data: h).record }.to_a
    end
    
    org_users = users.map do |role, users|
      users.map do |u|
        ou = organisation.organisation_users.find_or_initialize_by user: u
        ou.role = role
        ou
      end
    end

    organisation.transaction do
      org_users.flatten.each { |ou| ou.save! if ou.changed? }
      organisation.organisation_users = org_users.flatten
    end
  end

  private

  def user
    context.user || pick_user(organisation.users)
  end

  def all_members(options = {})
    paginate { client.organization_members(organisation.name, options) }
  end
end

