Factory.define :course do |c|
  c.sequence(:name){ |n| "Curso #{n}" }
  c.sequence(:path){ |n| "curso-#{n}" }
  c.association :owner, :factory => :user
  c.association :environment
  c.association :quota
end
