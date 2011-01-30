Factory.define :user_course_association do |a|
  a.association :user
  a.association :course
  a.role :member
  a.state "waiting"
end
