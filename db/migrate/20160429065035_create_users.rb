class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :token
      t.integer :github_id,    null: false
      t.string  :github_token
      t.string  :login,        null: false
      t.string  :avatar_url,   null: false
      t.string  :name
      t.string  :email

      t.timestamps null: false
    end

    add_index :users, :github_id
  end
end
