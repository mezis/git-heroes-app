class FindOrCreateRepository
  include Interactor

  delegate :data, :record, to: :context

  def call
    context.record = Repository.find_or_create_by!(github_id: data.id) do |r|
      assign_attributes(r, data)
      context.created = true
      binding.pry unless r.owner
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
      name:         data.name,
      description:  data.description,
    )
    record.owner = get_owner(data.owner)
  end

  def get_owner(h)
    result =
      case h.type
      when 'Organization' then
        FindOrCreateOrganisation.call(data: h)
      when 'User' then
        FindOrCreateUser.call(data: h)
      else
        raise "unknown owner type '#{h.type}'"
      end
    result.record
  end

end

