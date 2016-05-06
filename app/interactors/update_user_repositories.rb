class UpdateUserRepositories
  include GithubInteractor

  delegate :user, to: :context

  def call
    user.member_repositories = all_repositories.map { |h|
      FindOrCreateRepository.call(data: h).record
    }.to_a
  end

  private

  def all_repositories
    paginate { client.repositories }
  end

end
