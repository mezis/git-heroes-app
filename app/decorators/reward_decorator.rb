class RewardDecorator < SimpleDelegator

  def nature_text
    DATA[nature.to_sym][:title] % substitutions
  end

  def nature_info
    DATA[nature.to_sym][:details] % substitutions
  end

  def substitutions
    { login: user.login }
  end

  DATA = YAML.load %{
    ---
    :most_points_twice:
      :title:     Double Trouble
      :details:   Combo! Our top contributor has been @%<login>s, two weeks
                  in a row.
    :most_points:
      :title:     Hero of the Week
      :details:   Round of applause, @%<login>s outdid us all this week!
                  But will they stay un the podium?
    :reactivated:
      :title:     Zombie Arising
      :details:   We hadn't seen @%<login>s for a couple weeks. Hmmm...
                  Holiday or victim of a global pandemic?
    :top_newly_active:
      :title:     First Timer
      :details:   Everyone say hi! This is one of the first times
                  we see @%<login>s, and they're already going for the top.
    :most_cross_team_comments:
      :title:     Cooperative
      :details:   Standing out by being the person commenting most on other
                  teams' code, that's @%<login>s.
    :most_comments:
      :title:     Chatterbox
      :details:   Not that it's a bad thing. @%<login>s is our top commenter
                  this week.
    :most_pull_requests:
      :title:     Compulsive Coder
      :details:   Leave some coding to do for the rest of us!
                  @%<login>s has gotten the most pull requests merged.
    :most_other_merges:
      :title:     Executive Decider
      :details:   Not merging your own pull requests? Looks like
                  @%<login>s might end up doing it for you.
    :consistent_merge_time:
      :title:     Reliable
      :details:   Like clockwork! @%<login>s's pull requests get merged
                  right on schedule.
    :team_most_points:
      :title:     Team Guru
      :details:   Top contributor in their team! @%<login>s is your go-to
                  person.
    :second_most_points:
      :title:     Number Two
      :details:   It's good to be number two, @%<login>s — but watch out
                  for those sharks and lasers!
  }.strip.gsub(/^\s{4}/, '')
end
