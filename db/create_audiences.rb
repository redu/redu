def create_audiences
  Audience.create(:name => "Ensino Superior")
  Audience.create(:name => "Ensino Médio")
  Audience.create(:name => "Ensino Fundamental")
  Audience.create(:name => "Pesquisa")
  Audience.create(:name => "Empresas")
  Audience.create(:name => "Concursos")
  Audience.create(:name => "Pré-Vestibular")
  Audience.create(:name => "Certificações")
  Audience.create(:name => "Diversos")
end
