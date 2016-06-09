class UpdateRepositoryPullRequestsJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    repo =   options.fetch(:repository)
    result = UpdateRepositoryPullRequests.call(repository: repo)

    result.records.each do |record|
      UpdatePullRequestJob.perform_later(
        pull_request: record,
        actors:       actors | [repo.owner],
        parent:       self,
      )
    end
  end
end
