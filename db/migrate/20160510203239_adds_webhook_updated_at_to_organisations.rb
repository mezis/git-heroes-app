class AddsWebhookUpdatedAtToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :webhook_updated_at, :datetime
  end
end
