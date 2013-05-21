# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :message do
    sender { FactoryGirl.create(:user) }
    recipient { FactoryGirl.create(:user) }
    sequence(:subject) { |n| "Subject #{n}}" }
    sequence(:body) { |n| "Body #{n}}" }
  end
end
