# Given an Github PR hash, finds or creates pull requests
# (and update as necessary)
class FindOrCreatePullRequest
  include Interactor

  delegate :data, :repository, :record, to: :context

  def call
    context.record = repository.pull_requests.find_or_create_by!(github_id: data.id) do |pr|
      assign_attributes(pr, data)
      context.created = true
    end

    assign_attributes(record, data)
    if record.changed?
      context.updated = true
      record.save!
    end
  end

  private

  def assign_attributes(record, data)
    record.assign_attributes(
      github_number:      data.number,
      merged_at:          data.merged_at,
      status:             data.state.to_sym,
      created_at:         data.created_at,
      github_updated_at:  data.updated_at,
    )
    record.created_by = FindOrCreateUser.call(data: data.user).record
    if data.merged_by
      record.merged_by = FindOrCreateUser.call(data: data.user).record
    end
  end
end
