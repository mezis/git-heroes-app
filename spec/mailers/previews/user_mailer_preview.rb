class UserMailerPreview < ActionMailer::Preview

  def daily
    org = Organisation.where(enabled:true).sample
    user = org.users.sample
    UserMailer.daily(organisation: org, user: user).deliver
  end

  def weekly
    org = Organisation.where(enabled:true).sample
    user = org.users.sample
    UserMailer.weekly(organisation: org, user: user).deliver
  end

end
