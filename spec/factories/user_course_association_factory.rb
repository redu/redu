Factory.define :user_course_association do |a|
  a.association :user
  a.association :course
  #FIXME Colocar Role[:member]. Estava quebrando o rake spec.
  a.role 2
  a.state "waiting"
end
