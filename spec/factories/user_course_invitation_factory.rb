# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :user_course_invitation do
    sequence(:email) { |n| "email#{n}@example.com" }
    association :course
  end
end
