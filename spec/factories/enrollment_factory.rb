# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :enrollment do |e|
    e.association :user
    e.association :subject
    e.role :member
  end
end
