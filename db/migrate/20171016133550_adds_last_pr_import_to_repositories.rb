class AddsLastPrImportToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :prs_updated_at, :datetime
  end
end
