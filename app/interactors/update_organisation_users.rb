class UpdateOrganisationUsers
  include GithubInteractor

  delegate :user, :organisation, to: :context

  def call
    organisation.users = all_members.map { |hash|
      result = FindOrCreateUser.call(data: hash)
      context.fail! error: 'could not find/create user' unless result.success?
      result.record
    }.to_a
  end

  private

  def all_members
    paginate { client.organization_members(organisation.name) }
  end
end

