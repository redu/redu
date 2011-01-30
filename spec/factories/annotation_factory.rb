Factory.define :annotation do |a|
  a.content "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
  ullamco laboris nisi ut aliquip ex ea commodo consequat."
  a.association :user
  a.association :lecture
  a.asset_name { |an| an.lecture.name }
end
