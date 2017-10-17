FactoryGirl.define do
  factory :comment do
    github_id { Faker::Number.number(8) }
    pull_request
    user
    github_updated_at { Faker::Time.backward(365) }
  end
end
