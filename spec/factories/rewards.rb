FactoryGirl.define do
  factory :reward do
    organisation
    user
    nature { Reward.natures.values.sample }
    date { Faker::Date.backward(365) }
  end
end
