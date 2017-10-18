class AddUserIndices < ActiveRecord::Migration
  def change
    add_index :users, :throttle_left, where: 'github_token IS NOT NULL'
  end
end
