class TeamUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :team

  validates_presence_of :user, :team
end
