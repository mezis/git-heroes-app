class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.integer :github_id, null: false

      t.timestamps null: false
    end

    add_index :organisations, :name, unique: true
    add_index :organisations, :github_id, unique: true
  end
end
