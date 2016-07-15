class UpdateRepositoryPullRequests
  include GithubInteractor

  delegate :repository, :records, to: :context

  def call
    context.record_ids = Set.new
  
    if user.nil?
      Rails.logger.warn "cannot update #{repository.full_name}: no member user"
      return
    end

    all_pull_requests.each do |hash|
      result = FindOrCreatePullRequest.call(repository: repository, data: hash)
      context.record_ids << result.record.id if result.created || result.updated
    end
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= pick_user repository.users
  end

  def all_pull_requests
    paginate do
      client.pull_requests(
        repository.full_name, 
        state:    'all',
        sort:     'created',
        per_page: 10)
    end
  end
end
