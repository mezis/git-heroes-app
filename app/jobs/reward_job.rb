class RewardJob < BaseJob

  def perform(options = {})
    org = options[:organisation]
    date = options[:date]

    if org.nil?
      Organisation.find_each do |org|
        RewardJob.perform_later options.merge(organisation: org)
      end
    elsif date.nil?
      org.scores.pluck('DISTINCT date').sort.each do |date|
        RewardJob.perform_later options.merge(date: date.to_s)
      end
    else
      RewardService.new(organisation: org, date: Date.parse(date)).call
    end
  end

end
