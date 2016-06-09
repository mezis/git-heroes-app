class UpdatePullRequestJob < BaseJob
  def perform(options = {})
    pr = options.fetch(:pull_request)

    UpdatePullRequest.call(pull_request: pr)
    UpdatePullRequestComments.call(pull_request: pr)
  end
end

