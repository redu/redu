Factory.define(:student_profile) do |sp|
  sp.association :user
  sp.association :subject
end
