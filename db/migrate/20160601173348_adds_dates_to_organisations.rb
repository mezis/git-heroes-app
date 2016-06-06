class AddsDatesToOrganisations < ActiveRecord::Migration
  def up
    add_column :organisations, :scored_up_to,   :date
    add_column :organisations, :rewarded_up_to, :date
  end

  def down
    remove_column :organisations, :scored_up_to,   :date
    remove_column :organisations, :rewarded_up_to, :date
  end
end
