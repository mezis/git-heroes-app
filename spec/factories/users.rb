require 'faker'

FactoryGirl.define do
  factory :user do
    token       nil
    github_id   { Faker::Number.number(9).to_i }
    login       { Faker::Internet.user_name }
    admin       false

    trait :logged_in do
      token { Faker::Crypto.sha1 }
      github_token { Faker::Crypto.sha1 }
      throttle_limit 5000
      throttle_left  4000
      throttle_reset_at { 30.minutes.from_now }
    end
  end
end
