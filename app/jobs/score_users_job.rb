class ScoreUsersJob < BaseJob
  def perform(options = {})
    org = Organisation.find(options.fetch(:organisation_id))
    date = options[:date] ? Date.parse(options[:date]) : nil

    ScoreUsers.call(organisation: org, date: date)
  end
end
