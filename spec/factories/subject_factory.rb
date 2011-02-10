Factory.define :subject do |s|
  s.sequence(:title){ |n| "Módulo #{n}" }
  s.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"

  s.lectures {|l| [l.association(:lecture)] }
  s.association :owner, :factory => :user
  s.space {|sub| Factory(:space, :owner => sub.owner,
                         :course => Factory(:course, :owner => sub.owner))}
end
