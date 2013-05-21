# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory(:asset_report) do |ar|
    ar.association :enrollment
    ar.association :lecture
  end
end
