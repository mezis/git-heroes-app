class RewardJob < BaseJob

  def perform(options = {})
    org =     options[:organisation]
    date =    options[:date]
    actors =  options.fetch(:actors, [])

    if org.nil?
      Organisation.find_each do |org|
        RewardJob.perform_later(
          organisation: org, 
          actors:       actors | [org],
          parent:       self,
        )
      end
    elsif date.nil?
      org.scores.pluck('DISTINCT date').sort.each do |date|
        RewardJob.perform_later(
          organisation: org,
          date:         date.to_s,
          actors:       actors | [org],
          parent:       self,
        )
      end
    else
      RewardService.new(organisation: org, date: Date.parse(date)).call
    end
  end

end
