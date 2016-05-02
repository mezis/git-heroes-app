class UpdateOrganisationUsers
  include GithubInteractor

  delegate :user, :organisation, to: :context

  def call
    context.fail! 'missing user' unless user.present?
    context.fail! 'missing organisation' unless organisation.present?

    unless organisation.users.include?(user)
      context.fail! 'user is not organisation member'
    end

    client = GithubClient.new(user)

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

