class ScoreBackfill
  include Interactor

  def call
    Organisation.find_each do |org|
      repository_ids = org.repositories.enabled.pluck(:id)
      next unless repository_ids.any?

      oldest_pull_request = PullRequest.where(repository_id: repository_ids).order(:created_at).first
      next unless oldest_pull_request.present?

      date = oldest_pull_request.created_at.beginning_of_week.to_date
      while date < Date.current.beginning_of_week
        ScoreUsersJob.perform_later organisation: org, date: date.to_s, actors: [org]
        date += 1.week
      end
    end
  end
end
