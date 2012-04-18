Factory.define(:asset_report) do |ar|
  ar.association :enrollment
  ar.association :lecture
end
