class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.references :owner, polymorphic: true, index: true, null: false
      t.string     :name,      null: false
      t.integer    :github_id, null: false

      t.timestamps null: false
    end
    add_index :repositories, :github_id, unique: true
    add_index :repositories, :owner_id
  end
end
