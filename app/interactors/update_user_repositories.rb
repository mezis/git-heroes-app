class UpdateUserRepositories
  include GithubInteractor

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

  def all_repositories
    paginate { client.repositories }
  end

  def get_owner(h)
    result =
      case h.type
      when 'Organization' then
        FindOrCreateOrganisation.call(data: h)
      when 'User' then
        FindOrCreateUser.call(data: h)
      else
        raise "unknown owner type '#{h.type}'"
      end
    result.record
  end
end
