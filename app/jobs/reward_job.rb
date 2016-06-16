class RewardJob < BaseJob

  def perform(options = {})
    org =     options[:organisation]
    date =    options[:date]
    actors =  options.fetch(:actors, [])

    if org.nil?
      Organisation.find_each do |org|
        RewardJob.perform_later(
          organisation: org,
          date:         date,
          actors:       actors | [org],
          parent:       self,
        )
      end
      return
    end

    if date.nil?
      if org.scored_up_to.nil?
        logger.info 'organisation not scored yet'
        return
      end

      if org.rewarded_up_to.nil? || org.scored_up_to <= org.rewarded_up_to
        logger.info "organisation already rewarded"
        return
      end

      date = org.scored_up_to - 7
    else
      date = Date.parse(date)
    end

    RewardService.new(organisation: org, date: date).call
  end

end
