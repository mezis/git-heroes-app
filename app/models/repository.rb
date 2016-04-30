class Repository < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  has_many :user_repositories, dependent: :destroy
  has_many :users, through: :user_repositories, inverse_of: :member_repositories

  validates_presence_of :owner, :name, :github_id
end
