FactoryGirl.define do
  factory :user_setting do
    user nil
    weekly_email_at "2016-05-26 22:32:45"
    daily_email_at "2016-05-26 22:32:45"
    snooze_until "2016-05-26 22:32:45"
    weekly_email_enabled false
    daily_email_enabled false
  end
end
