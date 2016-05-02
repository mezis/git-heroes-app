class UpdatePullRequestJob < BaseJob
  def perform(options = {})
    pr = PullRequest.find(options[:pull_request_id])
    UpdatePullRequest.call(pull_request: pr)
    UpdatePullRequestComments.call(pull_request: pr)
  end
end

