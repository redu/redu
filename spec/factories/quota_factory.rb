# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :quota do
    multimedia 5.megabytes
    files 10.megabytes
  end

  factory :unused_quota, :class => :quota do
    multimedia 0
    files 0
  end
end
