# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user_course_association do |a|
    association :course
    association :user
    role :member
  end
end
