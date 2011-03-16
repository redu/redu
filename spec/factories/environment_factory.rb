Factory.define :environment do |e|
  e.sequence(:name) { |n| "Ambiente #{n}" }
  e.sequence(:path) { |n| "ambiente-#{n}" }
  e.sequence(:initials) { |n| "amb-#{n}" }
  e.association :owner, :factory => :user
end
