FactoryGirl.define do
  factory :lecture do
    sequence(:name) { |n| "Item #{n}" }
    association :lectureable, :factory => :page
    association :owner, :factory => :user
    association :subject
  end
end
