class Comment < ApplicationModel
  belongs_to :pull_request, inverse_of: :comments, counter_cache: true
  belongs_to :user, inverse_of: :comments
end
