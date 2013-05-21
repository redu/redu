# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exercise do
  end

  factory :complete_exercise, :parent => :exercise do
    maximum_grade 10
    after(:create) do |e, _|
      FactoryGirl.create(:complete_question, :exercise => e)
      FactoryGirl.create(:complete_question, :exercise => e)
      FactoryGirl.create(:complete_question, :exercise => e)
    end
  end
end
