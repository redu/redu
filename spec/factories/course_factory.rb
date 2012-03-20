FactoryGirl.define do
  factory :course do
    sequence(:name){ |n| "Curso #{n}" }
    sequence(:path){ |n| "curso-#{n}" }
    association :owner, :factory => :user
    association :environment
    association :quota, :factory => :quota
  end

  factory :complete_course, :parent => :course do
    description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    workload 40

    after_create do |c|
      c.spaces << Factory(:space, :owner => c.owner, :course => c)
    end
  end

end
