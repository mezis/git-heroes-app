FactoryGirl.define do
  factory :team do
    github_id { Faker::Number.number(8) }
    name { Faker::Team.name }
    slug { Faker::Internet.slug }
    organisation
  end
end
