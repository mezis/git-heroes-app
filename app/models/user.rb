class User < ActiveRecord::Base
  has_many :organisation_users, dependent: :destroy
  has_many :organisations, through: :organisation_users

  validates_presence_of :github_id, :login
end
