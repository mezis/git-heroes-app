# Iterates through pull request since `Repository#prs_updated_at`,
# and update this timestamp when done.
class PullRequestIterator
  def initialize(user:, repository:)
    @user = user
    @repo = repository
  end

  def each
    latest = Time.at(0)
    @repo.prs_updated_at ||= Time.at(0)

    client.paginate {
      client.pull_requests(
        @repo.full_name,
        state:     'all',
        sort:      'updated',
        direction: 'desc',
        per_page:   30,
      )
    }.each do |data|
      break if data.updated_at < @repo.prs_updated_at
      yield data
      latest = [latest, data.updated_at].compact.max
    end
    @repo.update_attributes!(prs_updated_at: latest)
  end

  private
  
  def client
    @client ||= GithubClient.new(@user)
  end

end

