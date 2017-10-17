FactoryGirl.define do
  factory :repository do
    name { Faker::App.name }
    github_id { Faker::Number.number(8) }

    association :owner, factory: :organisation
  end
end
