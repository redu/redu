def create_standard_partner
  Partner.create(:name => "CNS",
                 :email => "cns@redu.com.br",
                 :cnpj => "12.123.123/1234-12",
                 :address => "Beaker street")
end
