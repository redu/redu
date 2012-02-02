# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define(:licensed_invoice) do |i|
  i.period_start Date.today
  i.period_end(Date.today + 15)
  i.amount 150.25
end
