class RewardBackfill
  include Interactor

  def call
    Organisation.find_each do |org|
      org.scores.pluck('DISTINCT date').sort.each do |date|
        RewardJob.perform_later(
          organisation: org,
          date:         date.to_s,
          actors:       [org],
        )
      end
    end
  end
end
