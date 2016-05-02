class AddsCounterCaches < ActiveRecord::Migration
  def change
    add_column :organisations, :users_count,              :integer, default: 0, null: false
    add_column :organisations, :owned_repositories_count, :integer, default: 0, null: false
    add_column :users,         :owned_repositories_count, :integer, default: 0, null: false
    add_column :users,         :repositories_count,       :integer, default: 0, null: false
    add_column :repositories,  :users_count,              :integer, default: 0, null: false
  end
end
