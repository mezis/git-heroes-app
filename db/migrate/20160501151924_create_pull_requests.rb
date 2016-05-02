class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.integer     :github_id,                                   null: false
      t.integer     :github_number,                               null: false
      t.references  :repository, index: true, foreign_key: true,  null: false
      t.references  :created_by, index: true,                     null: false
      t.references  :merged_by,  index: true
      t.integer     :status,                                      null: false
      t.datetime    :merged_at
      t.datetime    :github_updated_at,                           null: false

      t.timestamps null: false
    end
    add_index :pull_requests, :github_id, unique: true
    add_foreign_key :pull_requests, :users, column: :created_by_id
    add_foreign_key :pull_requests, :users, column: :merged_by_id
  end
end
