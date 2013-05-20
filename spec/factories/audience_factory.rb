# -*- encoding : utf-8 -*-
Factory.define :audience do |a|
  a.sequence(:name) {|n| "Audience-#{n}"}
end
