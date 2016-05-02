class PullRequest < ActiveRecord::Base
  belongs_to :repository, inverse_of: :pull_requests
  belongs_to :created_by, class_name: 'User', inverse_of: :created_pull_requests
  belongs_to :merged_by, class_name: 'User', inverse_of: :merged_pull_requests

  enum status: { open: 1, closed: 2, merged: 3 }
end
