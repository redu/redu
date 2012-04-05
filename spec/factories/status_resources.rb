# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :status_resource do
      provider "MyString"
      type "MyString"
      thumb_url "MyString"
      title "MyString"
      description "MyString"
      link "MyString"
      status_id 1
    end
end