Factory.define :enrollment do |e|
  e.association :user
  e.association :subject
end
