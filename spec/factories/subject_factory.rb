# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :subject do
    sequence(:name){ |n| "Módulo #{n}" }
    description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
    association :owner, :factory => :user
    space {|sub| FactoryGirl.create(:space, :owner => sub.owner,
                         :course => FactoryGirl.create(:course, :owner => sub.owner))}
  end

  factory :complete_subject, :parent => :subject do
    finalized true

    after(:create) do |s,_|
      (1..3).each do
        s.lectures << FactoryGirl.create(:lecture, :owner => s.owner, :subject => s)
      end
    end
  end
end
