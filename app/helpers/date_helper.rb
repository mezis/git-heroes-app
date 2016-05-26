module DateHelper
  GREETINGS = %{
    What a lovely %s!
    Happy %s.
    I'm sure this'll be a great %s.
    Is %s your favourite day of the week?
    Hey, it's %s today.
    Fact: most %ss are great.
  }.strip.split(/\s*\n\s*/)

  def random_greeting
    GREETINGS.sample % Date.current.strftime('%A')
  end

  def human_date(time)
    date = time.to_date
    case Date.current - date
    when 1
      'yesterday'
    when 2..7
      "last #{date.strftime '%A'}"
    else
      date.strftime '%B %d'
    end
  end
end
