# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :message do
    sender { Factory(:user) }
    recipient { Factory(:user) }
    sequence(:subject) { |n| "Subject #{n}}" }
    sequence(:body) { |n| "Body #{n}}" }
  end
end
