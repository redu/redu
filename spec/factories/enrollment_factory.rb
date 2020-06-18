# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :enrollment do |e|
    e.association :user
    e.association :subject
    e.role :member
  end
end
