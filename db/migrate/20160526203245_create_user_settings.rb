class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.references :user, index: { unique: true }, foreign_key: true, null: false
      t.datetime :weekly_email_at
      t.datetime :daily_email_at
      t.datetime :snooze_until

      t.boolean  :weekly_email_enabled, null: false, default: true
      t.boolean  :daily_email_enabled,  null: false, default: true
      t.boolean  :newsletter_enabled,   null: false, default: true

      t.timestamps null: false
    end
  end
end
