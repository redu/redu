Factory.define :space do |s|
  s.sequence(:name) {|n| "Espaço #{n}"}
  s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
  s.submission_type 0

  s.association :owner, :factory => :user
  s.association :course, :factory => :course
end
