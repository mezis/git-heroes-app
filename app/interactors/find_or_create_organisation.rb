# Given an Github org hash, finds or creates Users.
class FindOrCreateOrganisation
  include Interactor

  delegate :data, :record, to: :context

  def call
    context.record = Organisation.find_or_create_by!(github_id: data.id) do |org|
      assign_attributes(org, data)
    end

    assign_attributes(record, data)
    record.save! if record.changed?
  end

  private

  def assign_attributes(org, data)
    org.assign_attributes(
      name:       data.login,
    )
  end
end
