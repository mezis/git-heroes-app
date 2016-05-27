class UserSettingsPolicy < SimpleDelegator
  def initialize(user, record)
    super UserPolicy.new(user, record.user)
  end
end
