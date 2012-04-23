Factory.define :log do |e|
  e.text "Lorem ipsum Ximbica"
  e.association :statusable, :factory => :user
  e.association :user, :factory => :user
  e.association :logeable, :factory => :user
  e.action "update"
end
