class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :github_id, null: false, index: true
      t.string :name, null: false
      t.references :organisation, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
