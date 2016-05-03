class OrganisationUser < ActiveRecord::Base
  validates_presence_of :organisation, :user
  belongs_to :organisation, counter_cache: :users_count
  belongs_to :user
  has_many :scores, class_name: 'OrganisationUserScore', dependent: :destroy
end
