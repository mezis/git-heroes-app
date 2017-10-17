FactoryGirl.define do
  factory :organisation_user_score do
    date { Faker::Date.backward(365).beginning_of_week }
    organisation
    user
    points { rand(100) }
    pull_request_count { rand(100) }
    pull_request_merge_time { rand(10000) }
  end
end
