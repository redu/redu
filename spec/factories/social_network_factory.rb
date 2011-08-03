Factory.define :social_network do |s|
  s.sequence(:name) {|n| "social network#{n}"}
  s.sequence(:url) { |n| "http://www.socialnetwork#{n}.com"}
  s.association :user, :factory => :user
end
