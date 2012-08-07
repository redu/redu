FactoryGirl.define do
  # Disciplina simples
  factory :space do |s|
    s.sequence(:name) {|n| "Espaço #{n}"}
    s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"

    s.association :owner, :factory => :user
    s.association :course, :factory => :course
  end
  # Disciplina completa, com módulos
  factory :complete_space, :parent => :space do
    after_create do |space|
      space.subjects << Factory(:complete_subject, :space => space)
    end
  end
end
