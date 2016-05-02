FactoryGirl.define do
  factory :pull_request do
    repository nil
    github_id 1
    github_number 1
    author nil
    merger nil
    status 1
  end
end
