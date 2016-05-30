class AddsMoreScoringData < ActiveRecord::Migration
  def up
    add_column :organisation_user_scores, :pull_request_merge_stddev, :integer
    add_column :organisation_user_scores, :other_merges,              :integer, null: false, default: 0
    add_column :organisation_user_scores, :comment_count,             :integer, null: false, default: 0
    add_column :organisation_user_scores, :self_comment_count,        :integer, null: false, default: 0
    add_column :organisation_user_scores, :other_comment_count,       :integer, null: false, default: 0
    add_column :organisation_user_scores, :cross_team_comment_count,  :integer, null: false, default: 0
    change_column_default :organisation_user_scores, :points, 0
    change_column_default :organisation_user_scores, :pull_request_count, 0
  end

  def down
    remove_column :organisation_user_scores, :pull_request_merge_stddev
    remove_column :organisation_user_scores, :other_merges
    remove_column :organisation_user_scores, :comment_count
    remove_column :organisation_user_scores, :self_comment_count
    remove_column :organisation_user_scores, :other_comment_count
    remove_column :organisation_user_scores, :cross_team_comment_count
  end
end
