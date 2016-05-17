class AddsMissingConstraints < ActiveRecord::Migration
  def change
    {
      integer: %w[
          comments.github_id
          comments.pull_request_id
          organisation_user_scores.user_id
          organisation_user_scores.organisation_id
          organisation_user_scores.points
          organisation_user_scores.pull_request_count
          organisation_users.organisation_id
          organisation_users.user_id
          team_users.user_id
          team_users.team_id
          teams.organisation_id
          user_repositories.user_id
          user_repositories.repository_id
        ],
      datetime: %w[
          comments.github_updated_at
        ],
      date: %w[
          organisation_user_scores.date
        ],
      string: %w[
          teams.slug
        ]
    }.each_pair do |type,columns|
      columns.each do |column|
        table, colname = column.split('.')
        change_column table, colname, type, null: false
      end
    end


    {
      organisation_users: %i[organisation_id user_id],
      team_users: %i[user_id team_id],
      user_repositories: %i[user_id repository_id],
    }.each_pair do |table,cols|
      delete %{
        DELETE FROM #{table}
        USING (
          SELECT id,
            RANK() OVER (PARTITION BY #{cols.join(', ')} ORDER BY created_at DESC)
          FROM #{table}
        ) t
        WHERE t.id = #{table}.id
          AND t.rank > 1
      }

      add_index table, cols, unique: true
    end
  end
end
