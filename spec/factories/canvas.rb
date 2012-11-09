# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :canvas, :class => Api::Canvas do
    association :user, :factory => :user
    association :client_application,
      :factory => :client_application
  end
end
