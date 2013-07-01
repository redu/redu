# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user do |u|
    u.sequence(:login) {|n| "usuario#{n}"}
    u.password "password"
    u.password_confirmation "password"
    u.sequence(:email) {|n| "usuario#{n}@redu.com"}
    u.sequence(:first_name) {|n| "Usuário #{n}"}
    u.sequence(:last_name) {|n| "da Silva #{n}"}
    u.tos "1"
    u.sequence(:birthday) {|n| 13.years.ago - n}
    u.role :member
    u.association :settings, :factory => :tour_setting
  end

  factory :partner_user, :parent => :user do
    after(:create) do |u,_|
      u.partners << FactoryGirl.create(:partner)
    end
  end
end
