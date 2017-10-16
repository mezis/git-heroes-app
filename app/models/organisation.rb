class Organisation < ApplicationModel
  validates_presence_of :name, :github_id

  has_many :organisation_users, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :repositories, as: :owner, dependent: :destroy
  has_many :teams, dependent: :destroy, inverse_of: :organisation
  has_many :scores, class_name: 'OrganisationUserScore', dependent: :destroy
  has_many :pull_requests, through: :repositories
  has_many :rewards, dependent: :destroy

  def to_param
    name
  end

  def login
    name
  end

  # An organisation is considered public if all its (known) repos are
  def public?
    !repositories.where(public: false).exists?
  end

  # do we have valid scores to display today?
  # FIXME: this will change if/when we move to daily scoring
  def scored?
    scored_up_to == Date.current.beginning_of_week
  end

  # do we have valid rewards to display today?
  def rewarded?
    rewarded_up_to == Date.current.beginning_of_week
  end
end
