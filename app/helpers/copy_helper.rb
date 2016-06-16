module CopyHelper
  # workday activity distribution
  # (deliveroo, H1 2016)
  # 5%	1
  # 10%	1
  # 25%	2
  # 50%	5
  # 75%	10
  # 90%	17
  # 95%	21
  # mean: 7.5
  # dev:  7.0
  def activity_copy(level)
    source = 
      if level <= 3
        ACTIVITY_COPY[:low]
      elsif level <= 12
        ACTIVITY_COPY[:medium]
      else
        ACTIVITY_COPY[:high]
      end
    source.sample
  end

  ACTIVITY_COPY = YAML.load <<~YAML
    :low:
      - Bit of a slow day? Or probably you were hyper focused on something.
      - Looks like maybe you had too many meetings?
      - Come on, we've seen you contribute a bit more :)
      - Hmmm, that feels a little low. Did we miss something?
      - Well, I'm certain we get get these figures to go up a bit today.
      - That's a good start. Read on for places to snatch up some karma...
    :medium:
      - Not bad at all; keep it coming!
      - Looks like this was a pretty good day for you.
      - Smooth. Now let's keep the good karma going.
    :high:
      - Let me just say this — you rock.
      - Wow, that was intense. Maybe take a breath today?
      - You were on a roll! Maybe don't work *that* hard.
      - With days like this, someone's gonna need a holiday.
      - You don't have to do *all* the things, you know.
      - Now, that's what I'm talking about.
      - Maybe leave some for the rest of the team though.
  YAML
end

