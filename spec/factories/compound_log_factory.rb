# -*- encoding : utf-8 -*-
Factory.define :compound_log do |e|
  e.association :statusable, :factory => :user
  e.association :user, :factory => :user
  e.logeable_type 'User'
  e.logs { |logs| [logs.association :log] }
end
