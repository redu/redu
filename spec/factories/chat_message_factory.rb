# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :chat_message do |c|
    c.association :user
    c.association :contact, :factory => :user
    c.sequence(:message){ |n| "Uma nova mensagem de texto - #{n}" }
  end
end
