# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :status_user_association do |c|
    c.association :user
    c.association :status, :factory => :activity
  end
end
