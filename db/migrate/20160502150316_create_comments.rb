class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :github_id
      t.references :pull_request, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :github_updated_at

      t.timestamps null: false
    end
    add_index :comments, :github_id
  end
end
