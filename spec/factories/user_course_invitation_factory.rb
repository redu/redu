Factory.define :user_course_invitation do |i|
  i.email "email@example.com"
  i.association :course
end
