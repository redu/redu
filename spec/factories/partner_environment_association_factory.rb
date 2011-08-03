Factory.define(:partner_environment_association) do |i|
  i.association :environment, :factory => :environment
  i.association :partner, :factory => :partner
  i.cnpj "12.123.123/1234-12"
end
