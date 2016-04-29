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

    organisation.users = all_members.map do |hash|
      User.find_or_create_by!(github_id: hash.id) do |o|
        o.login      = hash.login
        o.avatar_url = hash.avatar_url
      end
      # TODO: update users in background (to get name, email)
    end
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
    end
  end
end

