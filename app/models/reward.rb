class Reward < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :user

  # do not change indices.
  # order does matter — users only get one reward each cycle at most,
  # whichever comes first in the list (hashes are ordered!)
  enum nature: {
    most_points_twice:         0,
    most_points:               1,
    reactivated:               4,
    top_newly_active:          8,
    most_cross_team_comments: 10,
    most_comments:             5,
    most_pull_requests:        6,
    most_other_merges:         7,
    consistent_merge_time:     9,
    team_most_points:          2,
    second_most_points:        3,
  }

  validates_presence_of :organisation
  validates_presence_of :user
end
