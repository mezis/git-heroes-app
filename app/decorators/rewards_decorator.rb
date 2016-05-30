class RewardsDecorator < Array
  # content may change depending on the user
  def initialize(rewards:, user:)
    users_seen = Set.new
    grouped = rewards.group_by(&:nature)
    
    Reward.natures.each_key do |n|
      filter(n, grouped[n], user).each do |r|
        next if users_seen.include?(r.user)
        self << RewardDecorator.new(r)
      end
    end
  end

  private

  def filter(nature, rewards, user)
    return [] if rewards.blank?
    case nature
    when 'team_most_points'
      rewards.select { |r|
        (r.user.teams.enabled & user.teams.enabled).any?
      }
    else
      [rewards.sample]
    end
  end
end
