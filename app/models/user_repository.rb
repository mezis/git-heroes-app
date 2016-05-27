class UserRepository < ApplicationModel
  belongs_to :user, counter_cache: :repositories_count
  belongs_to :repository, counter_cache: :users_count

  validates_presence_of :user, :repository
end
