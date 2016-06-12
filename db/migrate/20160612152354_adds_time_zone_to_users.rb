class AddsTimeZoneToUsers < ActiveRecord::Migration
  def up
    add_column :users, :tz, :string, default: 'UTC', null: false
  end

  def down
    remove_column :users, :tz
  end
end
