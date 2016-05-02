class UpdateRepositoryPullRequestsJob < BaseJob
  def perform(options = {})
    repo = Repository.find(options[:repository_id])
    result = UpdateRepositoryPullRequests.call(repository: repo)

    # FIXME: catch failures / rate limits, retry

    result.records.each do |record|
      UpdatePullRequestJob.perform_later pull_request_id: record.id
    end
  end
end
