# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :favorite do |f|
    f.association :user
    f.association :favoritable, :factory => :status
  end
end
