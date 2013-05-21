# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
      email "test@redu.com.br"
      token "MyT0k3n"
    end
 end
