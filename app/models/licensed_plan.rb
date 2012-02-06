class LicensedPlan < Plan

  PLANS = {
    :free => {
      :name => "Plano Grátis",
      :price => 0,
      :video_storage_limit => 5.megabytes,
      :file_storage_limit => 5.megabytes
    },
    :instituicao_superior => {
      :name => "Instituição de Ensino Superior",
      :price => 3.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes
    },
    :instituicao_medio => {
      :name => "Instituição de Ensino Médio",
      :price => 2.30,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes
    },
    :curso_extensao => {
      :name => "Curso de Extensão",
      :price => 3.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes
    },
    :curso_corporativo => {
      :name => "Curso Corporativo",
      :price => 3.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes
    },
  }

  # Este plano não possui limite de membros
  def members_limit
    1.0/0 # Infinity
  end

  # Cria o invoice relativo a este plano. Por default, a data inicial é o hoje
  # e a data final é o último dia do mês. Inicia com amount nil, pois este só
  # será calculado ao final do mês, já que o seu valor depende da quantidade
  # de licenças utilizadas.
  def create_invoice(opts = {})
    options = {
      :invoice => {
      :period_start => Date.today,
      :period_end => Date.today.end_of_month,
      :plan => self }
    }.deep_merge(opts)

    options[:invoice].delete(:amount) # Não deve aceitar amount nos parâmetros
    LicensedInvoice.create(options[:invoice])
  end

  # Apenas cria o invoice, já que este plano não possui taxa de adesão
  def create_invoice_and_setup
    self.create_invoice
  end
end
