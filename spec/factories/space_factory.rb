FactoryGirl.define do
  factory :space do |s|
    s.sequence(:name) {|n| "Espaço #{n}"}
    s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"

    s.association :owner, :factory => :user
    s.association :course, :factory => :course
  end

  factory :complete_space, :parent => :space do
    after_create do |s|
      s.subjects << Factory(:complete_subject, :owner => s.owner, :space => s)
    end
  end
end
