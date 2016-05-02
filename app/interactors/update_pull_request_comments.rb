class UpdatePullRequestComments
  include GithubInteractor

  delegate :pull_request, :records, to: :context

  def call
    context.records = []
    all_comments.each do |hash|
      result = FindOrCreateComment.call(pull_request: pull_request, data: hash)
      records << result.record if result.created || result.updated
    end
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user pull_request.repository.users
  end

  def all_comments
    paginate do
      client.pull_request_comments(pull_request.repository.full_name, pull_request.github_number)
    end
  end
end

