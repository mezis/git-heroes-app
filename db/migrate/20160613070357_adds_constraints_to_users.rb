class AddsConstraintsToUsers < ActiveRecord::Migration
  def up
    remove_index :users, :login
    remove_index :users, :github_id
    add_index :users, :login,     unique: true
    add_index :users, :github_id, unique: true
  end

  def down
    remove_index :users, :login
    remove_index :users, :github_id
    add_index :users, :login
    add_index :users, :github_id
  end
end
