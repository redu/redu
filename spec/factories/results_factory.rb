# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :result do
    association :user
    association :exercise
  end

  factory :finalized_result, :parent => :result do
    state "finalized"
  end
end
