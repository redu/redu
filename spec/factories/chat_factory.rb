# -*- encoding : utf-8 -*-
Factory.define :chat  do |c|
  c.association :user
  c.association :contact, :factory => :user
end
