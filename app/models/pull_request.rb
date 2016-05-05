class PullRequest < ActiveRecord::Base
  belongs_to :repository, inverse_of: :pull_requests
  belongs_to :created_by, class_name: 'User', inverse_of: :created_pull_requests
  belongs_to :merged_by, class_name: 'User', inverse_of: :merged_pull_requests
  has_many :comments, inverse_of: :pull_request, dependent: :destroy

  enum status: { open: 1, closed: 2, merged: 3 }

  scope :with_status, ->(*s) { where status: statuses.slice(*s).values }

  validates_presence_of :merge_time, if: -> (r) { r.merged_at.present? }

  before_validation do
    if merged_at.present? && merge_time.blank?
      self.merge_time = merged_at - created_at
    end
  end
end
