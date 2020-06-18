# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :message do
    sender { FactoryBot.create(:user) }
    recipient { FactoryBot.create(:user) }
    sequence(:subject) { |n| "Subject #{n}}" }
    sequence(:body) { |n| "Body #{n}}" }
  end
end
