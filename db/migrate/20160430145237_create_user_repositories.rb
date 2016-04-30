class CreateUserRepositories < ActiveRecord::Migration
  def change
    create_table :user_repositories do |t|
      t.references :user, index: true, foreign_key: true
      t.references :repository, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
