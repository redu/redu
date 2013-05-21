# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user_environment_association do |a|
    a.association :user
    a.association :environment
    a.role :member
  end
end
