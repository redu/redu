Factory.define :subject do |s|
  s.sequence(:title){ |n| "Módulo #{n}" }
  s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
end
