# -*- encoding : utf-8 -*-
Factory.define :favorite do |f|
  f.association :user
  f.association :favoritable, :factory => :status
end
