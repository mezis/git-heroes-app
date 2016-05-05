class Organisation < ActiveRecord::Base
  validates_presence_of :name, :github_id

  has_many :organisation_users, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :repositories, as: :owner, dependent: :destroy
  has_many :teams, dependent: :destroy, inverse_of: :organisation
  has_many :scores, class_name: 'OrganisationUserScore', dependent: :destroy
  has_many :pull_requests, through: :repositories

  def login
    name
  end
end
