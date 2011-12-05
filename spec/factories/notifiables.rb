FactoryGirl.define do
  factory :notifiable do |n|
    n.association :user, :factory => :user
  end
end