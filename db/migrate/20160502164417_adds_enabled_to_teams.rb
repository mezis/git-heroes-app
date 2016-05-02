class AddsEnabledToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :enabled, :boolean, default:true, null:false
  end
end
