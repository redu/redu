# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :user_space_association do |a|
    a.association :user
    a.association :space
    a.role :member
  end
end
