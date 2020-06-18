# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :social_network do |s|
    s.name :facebook
    s.sequence(:url) { |n| "http://www.socialnetwork#{n}.com"}
    s.association :user, :factory => :user
  end
end
