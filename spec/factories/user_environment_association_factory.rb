# -*- encoding : utf-8 -*-
Factory.define :user_environment_association do |a|
  a.association :user
  a.association :environment
  a.role :member
end
