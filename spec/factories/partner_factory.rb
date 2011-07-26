Factory.define(:partner) do |i|
  i.sequence(:name) { |n| "Partner No #{n}" }
  i.sequence(:email) { |n| "partner_#{n}@redu.com.br" }
end
