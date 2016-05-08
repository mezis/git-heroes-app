class AddsRoleToTeamUsers < ActiveRecord::Migration
  def change
    add_column :team_users, :role, :integer, default: 1, null: false
  end
end
