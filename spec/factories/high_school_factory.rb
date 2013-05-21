# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :high_school do |h|
    h.sequence(:institution) { |n| "Institution #{n}" }
    h.end_year Date.today - 2.years
    h.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation."
  end
end
