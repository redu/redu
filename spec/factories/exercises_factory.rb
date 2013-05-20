# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exercise do
  end

  factory :complete_exercise, :parent => :exercise do
    maximum_grade 10
    after_create do |e|
      Factory(:complete_question, :exercise => e)
      Factory(:complete_question, :exercise => e)
      Factory(:complete_question, :exercise => e)
    end
  end
end
