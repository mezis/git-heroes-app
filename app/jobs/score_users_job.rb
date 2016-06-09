class ScoreUsersJob < BaseJob
  def perform(options = {})
    actors = options.fetch(:actors, [])
    org =  options.fetch(:organisation, nil)
    date = options[:date] ? Date.parse(options[:date]) : nil

    if org
      ScoreUsers.call(organisation: org, date: date)
      return
    end

    Organisation.find_each do |org| 
      ScoreUsersJob.perform_later(
        organisation: org,
        actors:       actors | [org],
        date:         date ? date.to_s : nil,
        parent:       self,
      )
    end
  end
end
