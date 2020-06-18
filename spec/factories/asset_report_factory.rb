# -*- encoding : utf-8 -*-
FactoryBot.define do
  factory(:asset_report) do |ar|
    ar.association :enrollment
    ar.association :lecture
  end
end
