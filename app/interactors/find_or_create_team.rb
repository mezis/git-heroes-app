class FindOrCreateTeam
  include Interactor

  delegate :organisation, :data, :record, to: :context

  def call
    context.record = Team.find_or_create_by!(github_id: data.id, enabled: true) do |u|
      assign_attributes(u, data)
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
      name:        data.name,
      slug:        data.slug,
      description: data.description,
    )
    record.organisation = organisation
  end
end
