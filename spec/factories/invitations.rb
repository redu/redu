# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
      email "test@redu.com.br"
      token "MyT0k3n"
    end

  factory :invite, :class => Invitation do
    email "test@redu.com.br"
    token "mYt0K3N"
  end
end
