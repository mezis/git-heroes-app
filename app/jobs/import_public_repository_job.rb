class ImportPublicRepositoryJob < BaseJob
  def perform(options = {})
    actors =  options.fetch(:actors, [])
    full_name = options.fetch(:name)

    ctx = AddPublicRepository.call(name: full_name)
    return unless ctx.record

    options = {
        repository: ctx.record, 
        actors:     actors | [ctx.record.owner],
        parent:     self,
    }

    if ctx.created
      ImportRepositoryPullRequestsJob.perform_later(**options)
    elsif ctx.updated
      UpdateRepositoryPullRequestsJob.perform_later(**options)
    end
  end
end
