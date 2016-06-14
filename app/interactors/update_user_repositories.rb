class UpdateUserRepositories
  include GithubInteractor

  delegate :user, to: :context

  def call
    user.member_repositories = all_repositories.map { |h|
      # double check the repository does exist
      # listing all repos will occasionally yield "dead" / removed repositories
      begin
        data = client.repo(h.full_name)
      rescue Octokit::NotFound
        next
      end
      FindOrCreateRepository.call(data: data).record
    }.to_a.compact
  end

  private

  def all_repositories
    paginate { client.repositories }
  end

end
