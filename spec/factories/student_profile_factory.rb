Factory.define(:student_profile) do |sp|
  sp.association :user
  sp.association :subject
  sp.association :enrollment
end
