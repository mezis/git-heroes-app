# Given an Github user hash, finds or creates Users.
class FindOrCreateUser
  include Interactor

  delegate :data, :record, to: :context

  def call
    context.record = User.find_or_create_by!(github_id: data.id) do |u|
      assign_attributes(u, data)
      context.created = true
    end

    assign_attributes(record, data)
    context.updated = true if record.changed?
    record.save! if record.changed?
  end

  private

  def assign_attributes(user, data)
    user.assign_attributes(
      login:      data.login,
      name:       user.name || data.name,
      email:      user.email || data.email,
    )
  end
end
