class UpdateRepositoryPullRequests
  include Interactor

  delegate :repository, :records, to: :context

  def call
    context.records = []
    all_pull_requests.each do |hash|
      result = FindOrCreatePullRequest.call(repository: repository, data: hash)
      records << result.record if result.created || result.updated
    end
  end

  private

  # pick a user to fetch pull requests
  # FIXME: round robin?
  def user
    @user ||= repository.users.order(:throttle_left).last
  end

  def client
    @client ||= GithubClient.new(user)
  end

  def all_pull_requests
    Enumerator.new do |y|
      client.pull_requests(repository.full_name, state: 'all', sort: 'created').each { |h| y << h }
      while uri = client.last_response.rels[:next]&.href
        client.get(uri).each { |h| y << h }
      end
    end.lazy
  end
end
