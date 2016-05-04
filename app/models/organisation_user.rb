class OrganisationUser < ActiveRecord::Base
  belongs_to :organisation, counter_cache: :users_count
  belongs_to :user

  validates_presence_of :organisation, :user
end
