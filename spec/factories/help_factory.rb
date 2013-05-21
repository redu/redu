# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :help do |e|
    e.text "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
    e.association :statusable, :factory => :lecture
    e.association :user, :factory => :user
    e.action :help
  end
end
