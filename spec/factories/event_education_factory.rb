# -*- encoding : utf-8 -*-
Factory.define :event_education do |e|
  e.sequence(:name) { |n| "Evento #{n}" }
  e.role "participant"
  e.year Date.today - 1.year
end
