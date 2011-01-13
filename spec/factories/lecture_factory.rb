Factory.define :lecture do |l|
  l.sequence(:name) { |n| "Item #{n}" }
  l.description "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
  l.association :lectureable, :factory => :page
  l.association :owner, :factory => :user
end
