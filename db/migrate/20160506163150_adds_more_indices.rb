class AddsMoreIndices < ActiveRecord::Migration
  def change
    add_index :repositories, %i[name owner_id owner_type]
    add_index :teams,        %i[name organisation_id]
    add_index :users,        %i[login]
  end
end
