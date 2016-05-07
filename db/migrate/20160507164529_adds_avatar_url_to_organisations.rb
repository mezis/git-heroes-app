class AddsAvatarUrlToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :avatar_url, :string
  end
end
