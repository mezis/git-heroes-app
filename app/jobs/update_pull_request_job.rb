class UpdatePullRequestJob < BaseJob
  def perform(options = {})
    pr = options.fetch(:pull_request)

    ctx = UpdatePullRequest.call(pull_request: pr)
    return unless ctx.created || ctx.updated
    UpdatePullRequestComments.call(pull_request: pr)
  end
end

