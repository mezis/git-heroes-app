class UpdatePullRequestJob < BaseJob
  def perform(options = {})
    pr = PullRequest.find(options[:pull_request_id])
    result = UpdatePullRequest.call(pull_request: pr)

    # FIXME: catch failures / rate limits, retry
  end
end

