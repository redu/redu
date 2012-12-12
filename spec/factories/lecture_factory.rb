Factory.define :lecture do |l|
  l.sequence(:name) { |n| "Item #{n}" }
  l.association :lectureable, :factory => :page
  l.association :owner, :factory => :user
  l.association :subject
end
