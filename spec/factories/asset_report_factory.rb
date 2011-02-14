Factory.define(:asset_report) do |ar|
  ar.association :student_profile
  ar.association :lecture
end
