# -*- encoding : utf-8 -*-
Factory.define :enrollment do |e|
  e.association :user
  e.association :subject
  e.role :member
end
