class UserSettings < ApplicationModel
  belongs_to :user, inverse_of: :settings

  delegate :to_param, to: :user

  # list of emails
  serialize :emails, JSON

  after_initialize do |r|
    r.emails ||= []
  end
end
