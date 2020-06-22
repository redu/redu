# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :license do
    name "Fulano de Tal"
    sequence(:login) do |n|
      "fulano#{n}"
    end
    email "fulano@redu.com.br"
    period_start "2012-02-02"
    period_end "2012-02-02"
    association :invoice, :factory => :licensed_invoice
    association :course
    role :member
  end
end
