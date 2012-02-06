FactoryGirl.define do
  factory :environment do
    sequence(:name) { |n| "Ambiente #{n}" }
    sequence(:path) { |n| "ambiente-#{n}" }
    sequence(:initials) { |n| "amb-#{n}" }
    association :owner, :factory => :user
  end

  factory :complete_environment, :parent => :environment do
    sequence(:name) { |n| "Ambiente #{n}" }
    sequence(:path) { |n| "ambiente-#{n}" }
    sequence(:initials) { |n| "amb-#{n}" }
    description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    association :owner, :factory => :user
  end
end

