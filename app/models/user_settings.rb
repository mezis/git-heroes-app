class UserSettings < ApplicationModel
  belongs_to :user, inverse_of: :settings

  delegate :to_param, to: :user
end
