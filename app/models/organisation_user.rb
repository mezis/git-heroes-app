class OrganisationUser < ActiveRecord::Base
  validates_presence_of :organisation, :user
  belongs_to :organisation
  belongs_to :user
end
