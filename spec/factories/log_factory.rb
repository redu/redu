# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :log do |e|
    e.association :statusable, :factory => :user
    e.association :user, :factory => :user
    e.association :logeable, :factory => :user
    e.action "update"
  end
end
