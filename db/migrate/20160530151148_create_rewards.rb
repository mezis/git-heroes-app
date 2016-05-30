class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.references :organisation, foreign_key: true, null: false
      t.references :user,         foreign_key: true, null: false
      t.integer :nature, null: false
      t.date :date, null: false

      t.timestamps null: false
    end

    add_index :rewards, %i[date organisation_id user_id]
  end
end
