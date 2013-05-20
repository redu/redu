# -*- encoding : utf-8 -*-
Factory.define :education do |e|
  e.association :educationable, :factory => :high_school
  e.association :user
end
