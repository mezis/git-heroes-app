class UserRepository < ActiveRecord::Base
  belongs_to :user
  belongs_to :repository

  validates_presence_of :user, :repository
end
