class AddEmailsPerOrg < ActiveRecord::Migration
  def up
    add_column :user_settings, :emails, :text
    add_column :organisation_users, :email, :string
  end

  def down
    remove_column :user_settings, :emails
    remove_column :organisation_users, :email
  end
end
