FactoryGirl.define do
  factory :invitation do
      sequence(:email) { |i| "usuario#{i}@redu.com.br" }
      token "MyT0k3n"
    end
 end
