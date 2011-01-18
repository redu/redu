Factory.define :user do |u|
  u.sequence(:login) {|n| "usuario#{n}"}
  u.password "password"
  u.password_confirmation "password"
  u.sequence(:login_slug) {|n| "usuario#{n}"}
  u.sequence(:email) {|n| "usuario#{n}@redu.com"}
  u.sequence(:first_name) {|n| "Usuário #{n}"}
  u.sequence(:last_name) {|n| "da Silva #{n}"}
  u.tos "1"
  u.sequence(:birthday) {|n| 13.years.ago - n}
  u.role :member
end
