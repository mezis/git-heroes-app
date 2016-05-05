class AddsMergeTimeToPullRequests < ActiveRecord::Migration
  def up
    add_column :pull_requests, :merge_time, :integer

    update %{
      UPDATE pull_requests
      SET merge_time = EXTRACT(EPOCH FROM merged_at - created_at)
      WHERE merged_at IS NOT NULL
    }
  end

  def down
    remove_column :pull_requests, :merge_time
  end
end
