require 'faker'

FactoryGirl.define do
  factory :organisation do
    name Faker::Internet.user_name
    github_id Faker::Number.number(9).to_i
  end
end
