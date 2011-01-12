Factory.define :environment do |e|
  e.sequence(:name) { |n| "Ambiente #{n}"}
  e.sequence(:path) { |n| "ambiente-#{n}"}

  e.association :owner, :factory => :user
end
