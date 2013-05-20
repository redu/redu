# -*- encoding : utf-8 -*-
Factory.define(:asset_report) do |ar|
  ar.association :enrollment
  ar.association :lecture
end
