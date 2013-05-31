# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :space do |s|
    s.sequence(:name) {|n| "Espaço #{n}"}
    s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"

    s.association :owner, :factory => :user
    s.course { |space| FactoryGirl.create(:course, :owner => space.owner) }

    after(:create) { |s| s.create_space_association_for_users_course }
  end

  factory :complete_space, :parent => :space do
    after(:create) do |s,_|
      s.subjects << FactoryGirl.create(:complete_subject, :owner => s.owner, :space => s)
    end
  end
end
