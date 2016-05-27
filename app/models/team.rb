class Team < ApplicationModel
  belongs_to :organisation, inverse_of: :teams
  has_many :team_users, dependent: :destroy
  has_many :users, through: :team_users

  validates_presence_of :organisation

  scope :enabled, -> { where(enabled:true) }

  def to_param
    slug
  end
end
