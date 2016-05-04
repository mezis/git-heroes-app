class CreateOrganisationUserScores < ActiveRecord::Migration
  def change
    create_table :organisation_user_scores do |t|
      t.date :date
      t.references :user, index: true, foreign_key: true
      t.references :organisation, index: true, foreign_key: true
      t.integer :points
      t.integer :pull_request_count
      t.integer :pull_request_merge_time

      t.timestamps null: false
    end

    add_index :organisation_user_scores, %i[date user_id organisation_id], 
      unique: true,
      name:   'organisation_user_scores_on_date_user_org'
  end
end
