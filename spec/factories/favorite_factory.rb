Factory.define :favorite do |f|
  c.association :user
  c.association :favoritable, :factory => :lecture
end
