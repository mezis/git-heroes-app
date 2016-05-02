# Given an Github org hash, finds or creates Users.
class FindOrCreateOrganisation
  include Interactor

  delegate :data, :record, to: :context

  def call
    context.record = Organisation.find_or_create_by!(github_id: data.id) do |org|
      assign_attributes(org, data)
      context.created = true
    end

    assign_attributes(record, data)
    if record.changed?
      context.updated = true
      record.save!
    end
  end

  private

  def assign_attributes(org, data)
    org.assign_attributes(
      name:       data.login,
    )
  end
end
