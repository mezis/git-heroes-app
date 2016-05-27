class OrganisationUser < ApplicationModel
  belongs_to :organisation, counter_cache: :users_count
  belongs_to :user

  validates_presence_of :organisation, :user

  enum role: { member: 1, admin: 2 }
end
