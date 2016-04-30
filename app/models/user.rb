class User < ActiveRecord::Base
  has_many :organisation_users, dependent: :destroy
  has_many :organisations, through: :organisation_users
  has_many :user_repositories, dependent: :destroy
  has_many :member_repositories, class_name: 'Repository', through: :user_repositories, source: :repository, inverse_of: :users
  has_many :owner_repositories, as: :owner

  validates_presence_of :github_id, :login
end
