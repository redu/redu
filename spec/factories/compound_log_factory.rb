Factory.define :compound_log do |e|
  e.association :statusable, :factory => :user
  e.association :user, :factory => :user
  e.logs { |logs| [logs.association :log] }
end
