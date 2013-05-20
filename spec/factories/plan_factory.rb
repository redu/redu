# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :plan do
    state "active"
    sequence(:name){ |n| "Plano #{n}"}
    video_storage_limit 1024
    members_limit 30
    file_storage_limit 1024
    price 29.9
    yearly_price(29.9 * 12)
    association :billable, :factory => :course
    association :user
    current true
  end

  factory :active_package_plan, :class => :package_plan do
    state "active"
    sequence(:name) { "Package Plan #{n}" }
    video_storage_limit 1024
    members_limit 20
    file_storage_limit 1024
    price 9.99
    yearly_price (9.99 * 12)
    membership_fee 9.99
    association :billable, :factory => :course
    association :user
    current true
  end

  factory :active_licensed_plan, :class => :licensed_plan do
    state "active"
    sequence(:name) { "Licensed Plan #{n}" }
    video_storage_limit 1024
    file_storage_limit 1024
    price 3.00
    association :billable, :factory => :environment
    association :user
    current true
  end
end
