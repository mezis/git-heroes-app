class AddsIndices < ActiveRecord::Migration
  def change
    add_index :pull_requests, :merged_at
    add_index :pull_requests, :created_at
    add_index :comments, :created_at
  end
end
