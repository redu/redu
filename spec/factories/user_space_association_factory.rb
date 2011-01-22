Factory.define :user_space_association do |a|
  a.association :user
  a.association :space
  a.role :member
  a.status "approved"
  #a.association :access_key
end
