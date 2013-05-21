# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :answer do |e|
    e.text "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
  ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
  velit esse cillum dolore eu fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non proident, sunt in
  culpa qui officia deserunt mollit anim id est laborum"
    e.association :statusable, :factory => :seminar_youtube
    e.association :in_response_to, :factory => :activity
    e.association :user, :factory => :user
  end
end
