class UpdateOrganisationUsers
  include Interactor

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

  def client
    @client ||= GithubClient.new(user)
  end

  def all_members
    Enumerator.new do |y|
      client.organization_members(organisation.name).each { |h| y << h }
      while uri = client.last_response.rels[:next]&.href
        client.get(uri).each { |h| y << h }
      end
    end.lazy
  end
end

