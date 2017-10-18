class UpdateUserRepositories
  include GithubInteractor

  delegate :user, to: :context

  def call
    context.created = []
    context.updated = []
    user.member_repositories = all_repositories.map { |h|
      # double check the repository does exist
      # listing all repos will occasionally yield "dead" / removed repositories
      begin
        data = client.repo(h.full_name)
      rescue Octokit::NotFound
        next
      end
      result = FindOrCreateRepository.call(data: data)
      if result.created
        context.created << result.record
      elsif result.updated
        context.updated << result.record
      end
      result.record
    }.to_a.compact
  end

  private

  def all_repositories
    paginate { client.repositories(per_page: 10) }
  end
end
