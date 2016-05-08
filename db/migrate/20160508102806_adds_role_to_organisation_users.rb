class AddsRoleToOrganisationUsers < ActiveRecord::Migration
  def change
    add_column :organisation_users, :role, :integer, default: 1, null: false
  end
end
