class OrganisationUserScore < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :user

  # validates_presence_of :organisation, :user
  validates_numericality_of :points, :pull_request_count
  validates_numericality_of :pull_request_merge_time, if: -> (r) { r.pull_request_count > 0 }
  validate :date_is_start_or_week

  def date_is_start_or_week
    unless date == date.beginning_of_week
      errors.add :date, 'not beginning of week'
    end
  end
end
