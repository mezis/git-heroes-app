FactoryGirl.define do
  factory :user_settings do
    user
    weekly_email_at { Faker::Time.forward(2) }
    daily_email_at { Faker::Time.forward(2) }
    snooze_until { 1.day.ago }
    weekly_email_enabled false
    daily_email_enabled false
  end
end
