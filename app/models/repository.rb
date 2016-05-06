class Repository < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, counter_cache: :owned_repositories_count
  has_many :user_repositories, dependent: :destroy
  has_many :users, through: :user_repositories, inverse_of: :member_repositories
  has_many :pull_requests, dependent: :destroy, inverse_of: :repository

  validates_presence_of :owner, :name, :github_id

  scope :enabled, -> { where(enabled:true) }

  def to_param
    name
  end

  def full_name
    "#{owner.login}/#{name}"
  end
end
