class AddsUserTokenIndex < ActiveRecord::Migration
  def change
    add_index :users, :token
  end
end
