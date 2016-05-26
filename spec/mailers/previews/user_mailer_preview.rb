# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/daily
  def daily
    org = Organisation.where(enabled:true).sample
    user = org.users.sample
    UserMailer.daily(organisation: org, user: user).deliver
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/weekly
  def weekly
    UserMailer.weekly
  end

end
