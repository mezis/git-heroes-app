# Import all PRs in a repo.
# The "cheat" is to fetch the most recently created pull request, which has the
# highest number.
class ImportRepositoryPullRequestsJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    r = options.fetch(:repository)

    max = RepositoryPullRequestCounter.call(repository: r).number

    1.upto(max) do |n|
      ImportPullRequestJob.perform_later(
        repository: r,
        number:     n,
        actors:     actors | [r.owner],
        parent:     self,
      )
    end
  end
end
