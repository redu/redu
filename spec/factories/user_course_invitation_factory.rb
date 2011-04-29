Factory.define :user_course_invitation do |i|
  i.sequence(:email) { |n| "email#{n}@example.com" }
  i.association :course
end
