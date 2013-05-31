# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice do
    association :user
  end
end
