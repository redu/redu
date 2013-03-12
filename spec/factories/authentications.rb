# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
      association :user
      provider "some-provider"
      sequence :uid do |n|
        "JIOjwqfqwfj#{n}"
      end
    end
end
