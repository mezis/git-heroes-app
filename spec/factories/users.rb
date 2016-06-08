require 'faker'

FactoryGirl.define do
  factory :user do
    token       nil
    github_id   Faker::Number.number(9).to_i
    login       Faker::Internet.user_name
    avatar_url  'deprecated'
  end
end
