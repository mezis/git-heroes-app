class ImportPullRequestJob < BaseJob
  def perform(options = {})
    r = options.fetch(:repository)
    n = options.fetch(:number)

    ctx = ImportPullRequest.call(repository: r, number: n)
    return unless ctx.record
    UpdatePullRequestComments.call(pull_request: ctx.record)
  end
end


