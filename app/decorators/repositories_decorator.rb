class RepositoriesDecorator < Delegator
  def initialize(collection, organisation:)
    @collection = collection
    @organisation = organisation
  end

  def __getobj__
    @wrapped ||= @collection.map { |r|
      # RepositoryDecorator.new(r, contributors: [])
      RepositoryDecorator.new(r, contributors: contributors[r.id])
    }
  end

  def to_ary
    __getobj__.send(:to_ary)
  end

  private

  def contributors
    return @contributors if @contributors
    
    org_users = @organisation.users.index_by(&:id)
    @contributors = PullRequest.
      where(repository_id: @collection.map(&:id)).
      select(:created_by_id, :repository_id).
      group(:created_by_id, :repository_id).
      group_by(&:repository_id).
      each_with_object(Hash.new([])) { |(repo_id,prs),h|
        h[repo_id] = prs.map { |pr|
          org_users[pr.created_by_id]
        }.compact
      }
  end
end
