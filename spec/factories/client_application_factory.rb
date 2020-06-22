# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :client_application do
    sequence(:name) { |n| "My ximbica app No #{n}" }
    url "http://localhost:3000"
    association :user, :factory => :user
  end
end
