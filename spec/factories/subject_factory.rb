# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory :subject do
    sequence(:name){ |n| "Módulo #{n}" }
    description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
    association :owner, :factory => :user
    space {|sub| FactoryBot.create(:space, :owner => sub.owner,
                         :course => FactoryBot.create(:course, :owner => sub.owner))}
  end

  factory :complete_subject, :parent => :subject do
    finalized true

    after(:create) do |s,_|
      (1..3).each do
        s.lectures << FactoryBot.create(:lecture, :owner => s.owner, :subject => s)
      end
    end
  end
end
