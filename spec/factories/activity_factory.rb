# -*- encoding : utf-8 -*-
Factory.define :activity do |e|
  e.text "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation"
  e.association :statusable, :factory => :user
  e.association :user, :factory => :user
  e.action :update
end
