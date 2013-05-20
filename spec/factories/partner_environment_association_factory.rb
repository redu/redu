# -*- encoding : utf-8 -*-
Factory.define(:partner_environment_association) do |i|
  i.association :environment, :factory => :environment
  i.association :partner, :factory => :partner
  i.cnpj "12.123.123/1234-12"
  i.address "Great Street"
  i.company_name "Cool Inc."
end
