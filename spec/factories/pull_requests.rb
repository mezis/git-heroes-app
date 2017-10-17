FactoryGirl.define do
  factory :pull_request do
    repository
    github_id { Faker::Number.number(8) }
    github_number { Faker::Number.number(5) }
    status 1 # open
    github_updated_at { Faker::Time.backward(365) }

    association :created_by, factory: :user
  end
end
