# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    statement "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  end

  factory :complete_question, :parent => :question do
    after(:create) do |q, _|
      FactoryGirl.create(:alternative, :correct => true, :question => q)
      FactoryGirl.create(:alternative, :correct => false, :question => q)
      FactoryGirl.create(:alternative, :correct => false, :question => q)
      q.alternatives.reload
    end
  end
end
