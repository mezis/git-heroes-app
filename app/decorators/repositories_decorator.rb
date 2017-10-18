class RepositoriesDecorator < SimpleDelegator
  def initialize(collection)
    @collection = collection
    wrapped = @collection.map { |r|
      RepositoryDecorator.new(
        r, 
        contributors:      -> { _contributors(r.id) },
        contributor_count: -> { _contributor_count(r.id) },
      )
    }
    super(wrapped)
  end

  def to_ary
    __getobj__.send(:to_ary)
  end

  private

  LIMIT = 20

  def _contributors(repo_id)
    _calculate_contributors
    @_contributors.fetch(repo_id, [])
  end

  def _contributor_count(repo_id)
    _calculate_contributor_count
    @_contributor_count.fetch(repo_id, 0)
  end

  def _calculate_contributors
    return if @_contributors

    repository_ids = @collection.map(&:id).join(',')
    data = PullRequest.connection.select_rows(<<-SQL, "Top Contributors Load")
      with
      p as (
        select
            true
            , created_by_id
            , repository_id
            , rank() over (
                partition by repository_id
                order by count(1) desc
              ) rank
            , count(id)
        from pull_requests
        where repository_id IN (#{repository_ids})
        and merged_at is not null
        group by created_by_id, repository_id
      )
      select created_by_id, repository_id from p
      where rank <= #{LIMIT}
      ;
    SQL

    data.map! { |a,b| [a.to_i, b.to_i] }
    users = User.where(id: data.map(&:first)).index_by(&:id)

    @_contributors =
      data.group_by(&:last).each_with_object(Hash.new { [] }) do |(repo_id,l),h|
        h[repo_id] = l.map(&:first).map { |id| users[id] }.compact.take(LIMIT)
      end
  end

  def _calculate_contributor_count
    return if @_contributor_count

    @_contributor_count = PullRequest.
      where(repository_id: @collection.map(&:id)).
      where.not(merged_at: nil).
      group(:repository_id).
      distinct.
      count(:created_by_id)
  end


end
