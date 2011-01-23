Factory.define(:plan) do |p|
  p.state "active"
  p.sequence(:name){ |n| "Plano #{n}"}
  p.video_storage_limit 1024
  p.members_limit 30
  p.file_storage_limit 1024
  p.price 29.9
  p.association :billable, :factory => :course
  p.association :user
end
