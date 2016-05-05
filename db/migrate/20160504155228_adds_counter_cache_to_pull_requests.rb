class AddsCounterCacheToPullRequests < ActiveRecord::Migration
  def up
    add_column :pull_requests, :comments_count, :integer, default: 0, null: false

    update %{
      UPDATE pull_requests
      SET comments_count = total
      FROM (
        SELECT COUNT(comments.id) AS total, pull_request_id
        FROM comments
        LEFT JOIN pull_requests
          ON comments.pull_request_id = pull_requests.id
        GROUP BY pull_request_id
      ) counts
      WHERE counts.pull_request_id = id
    }
  end

  def down
    add_column :pull_requests, :comments_count
  end
end
