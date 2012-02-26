Factory.define(:partner) do |i|
  i.sequence(:name) { |n| "Partner No #{n}" }
  i.sequence(:email) { |n| "partner_#{n}@redu.com.br" }
  i.cnpj "12.123.123/1234-12"
  i.address "Great Street"
end
