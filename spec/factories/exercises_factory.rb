# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :exercise do
  end

  factory :complete_exercise, :parent => :exercise do
    maximum_grade 10
    after(:create) do |e, _|
      FactoryBot.create(:complete_question, :exercise => e)
      FactoryBot.create(:complete_question, :exercise => e)
      FactoryBot.create(:complete_question, :exercise => e)
    end
  end
end
