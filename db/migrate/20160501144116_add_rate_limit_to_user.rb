class AddRateLimitToUser < ActiveRecord::Migration
  def change
    add_column :users, :throttle_limit, :integer
    add_column :users, :throttle_left, :integer
    add_column :users, :throttle_reset_at, :datetime
  end
end
