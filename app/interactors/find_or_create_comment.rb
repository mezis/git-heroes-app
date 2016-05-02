class FindOrCreateComment
  include Interactor

  delegate :data, :pull_request, :record, to: :context

  def call
    context.record = pull_request.comments.find_or_create_by!(github_id: data.id) do |c|
      assign_attributes(c, data)
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
      created_at:         data.created_at,
      github_updated_at:  data.updated_at,
    )
    record.user = FindOrCreateUser.call(data: data.user).record
  end
end
