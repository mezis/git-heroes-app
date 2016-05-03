class CreateOrganisationUserScores < ActiveRecord::Migration
  def change
    create_table :organisation_user_scores do |t|
      t.date :date
      t.references :organisation_user, index: true, foreign_key: true
      t.integer :points
      t.integer :pull_request_count
      t.integer :pull_request_merge_time

      t.timestamps null: false
    end

    add_index :organisation_user_scores, :date
  end
end
