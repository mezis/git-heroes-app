class MoveTzToSettings < ActiveRecord::Migration
  def up
    add_column :user_settings, :tz, :string, null: false, default: 'UTC'
    execute %{
      UPDATE users
      SET tz = users.tz
      FROM user_settings
      WHERE users.id = user_settings.user_id
    }
    remove_column :users, :tz
  end

  def down
    add_column :users, :tz, :string, null: false, default: 'UTC'
    execute %{
      UPDATE user_settings
      SET tz = users.tz
      FROM users
      WHERE users.id = user_settings.user_id
    }
    remove_column :user_settings, :tz
  end
end
