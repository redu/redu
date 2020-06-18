# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :experience do |e|
    e.sequence(:title) { |n| "Developer #{n}"}
    e.company "Company"
    e.start_date Date.today - 6.months
    e.end_date Date.today - 10.days
    e.current false
    e.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
    e.association :user
  end
end
