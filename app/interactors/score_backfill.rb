class ScoreBackfill
  include Interactor

  def call
    Organisation.find_each do |org|
      repository_ids = org.repositories.enabled.pluck(:id)
      oldest_pull_request = PullRequest.where(repository_id: repository_ids).order(:created_at).first
      date = oldest_pull_request.created_at.beginning_of_week.to_date
      while date < Date.current
        ScoreUsersJob.perform_later organisation_id: org.id, date: date.to_s
        date += 1.week
      end
    end
  end
end
