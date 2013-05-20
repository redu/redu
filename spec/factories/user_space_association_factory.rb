# -*- encoding : utf-8 -*-
Factory.define :user_space_association do |a|
  a.association :user
  a.association :space
  a.role :member
end
