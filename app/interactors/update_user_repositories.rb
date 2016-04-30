class UpdateUserRepositories
  include Interactor

  delegate :user, to: :context

  def call
    user.member_repositories = all_repositories.map { |h|
      Repository.find_or_create_by!(github_id: h.id) do |r|
        r.name  = h.name
        r.owner = get_owner(h.owner)
        binding.pry unless r.owner
      end
    }.to_a
  end

  private

  def client
    @client ||= GithubClient.new(user)
  end

  def all_repositories
    Enumerator.new do |y|
      client.repositories.each { |h| y << h }
      while uri = client.last_response.rels[:next]&.href
        client.get(uri).each { |h| y << h }
      end
    end.lazy
  end

  def get_owner(h)
    result =
      case h.type
      when 'Organization' then
        FindOrCreateOrganisation.call(data: h)
      when 'User' then
        FindOrCreateUser.call(data: h)
      else
        context.fail! error: "unknown owner type '#{h.type}'", metadata: h
      end
    context.fail! 'could not get owner' unless result.success?
    result.record
  end
end
