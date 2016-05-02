class AddEnabledToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :enabled, :boolean, default: false, null: false
    add_column :repositories,  :enabled, :boolean, default: false, null: false
  end
end
