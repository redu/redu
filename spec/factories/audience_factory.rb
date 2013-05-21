# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :audience do |a|
    a.sequence(:name) {|n| "Audience-#{n}"}
  end
end
