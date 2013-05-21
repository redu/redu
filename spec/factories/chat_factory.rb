# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :chat do |c|
    c.association :user
    c.association :contact, :factory => :user
  end
end
