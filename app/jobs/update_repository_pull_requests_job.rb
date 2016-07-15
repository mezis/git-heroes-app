class UpdateRepositoryPullRequestsJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    repo =   options.fetch(:repository)
    result = UpdateRepositoryPullRequests.call(repository: repo)

    result.record_ids.each do |id|
      UpdatePullRequestJob.perform_later(
        pull_request: PullRequest.find(id),
        actors:       actors | [repo.owner],
        parent:       self,
      )
    end
  end
end
