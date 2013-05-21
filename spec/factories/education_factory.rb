# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :education do |e|
    e.association :educationable, :factory => :high_school
    e.association :user
  end
end
