class PackagePlan < Plan

  PLANS = {
    :free => {
      :name => "Professor Grátis (3 meses)",
      :price => 0,
      :yearly_price => 0,
      :video_storage_limit => 10.megabytes,
      :file_storage_limit => 5.megabytes,
      :members_limit => 10
    },
    :professor_lite => {
      :name => "Professor Lite",
      :price => 13.99,
      :yearly_price => 139.90,
      :video_storage_limit => 30.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 20
    },
    :professor_standard => {
      :name => "Professor Standard",
      :price => 56.99,
      :yearly_price => 569.90,
      :video_storage_limit => 90.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 100
    },
    :professor_plus => {
      :name => "Professor Plus",
      :price => 243.99,
      :yearly_price => 2439.90,
      :video_storage_limit => 150.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 500
    },
    :empresas_lite => {
      :name => "Empresa Lite",
      :price => 210.99,
      :yearly_price => 2109.90,
      :video_storage_limit => 250.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 30
    },
    :empresas_standard => {
      :name => "Empresa Standard",
      :price => 248.99,
      :yearly_price => 2489.90,
      :video_storage_limit => 500.megabytes,
      :file_storage_limit => 250.megabytes,
      :members_limit => 50
    },
    :empresas_plus => {
      :name => "Empresa Plus",
      :price => 858.99,
      :yearly_price => 8589.90,
      :video_storage_limit => 1000.megabytes,
      :file_storage_limit => 250.megabytes,
      :members_limit => 200
    },
    :instituicao_plus => {
      :name => "Instituição Plus",
      :price => 1280.99,
      :yearly_price => 12809.90,
      :video_storage_limit => 800.megabytes,
      :file_storage_limit => 75.megabytes,
      :members_limit => 600
    },
    :instituicao_lite => {
      :name => "Instituição Lite",
      :price => 251.99,
      :yearly_price => 2519.90,
      :video_storage_limit => 500.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 100
    },
    :instituicao_standard => {
      :name => "Instituição Standard",
      :price => 730.99,
      :yearly_price => 7309.90,
      :video_storage_limit => 800.megabytes,
      :file_storage_limit => 50.megabytes,
      :members_limit => 300
    },
  }

  validates_presence_of :members_limit, :yearly_price

  # Cria um Invoice com o amount correto para este plano. O amount do invoice é
  # calculado dividindo-se o price do plano pela quantidade de dias restantes até
  # o último dia do mês atual. Caso nenhuma opção seja informada, a data inicial
  # será Date.tomorrow e a final de hoje a 30 dias, além disso o amount é
  # calculado para esse período.
  #
  # O invoice só é gerado o amount informado for maior do que zero. Para forçar
  # a criação de invoices independente do preço do plano, passar a opção
  # :force => true
  #
  # Como no exemplo abaixo:
  #
  # plan.price
  # => 20.00
  # Date.today
  # => Thu, 13 Jan 2011
  # invoice = plan.create_invoice
  # invoice.amount
  # => 11.61 # (31 dias - 13 dias) * (20 / 31 dias)
  def create_invoice(opts = {})
    options = {
      :invoice => {
      :period_start => Date.today.tomorrow,
      :period_end => Date.today.advance(:days => 30),
      :amount => self.price,
      :plan => self,
    },
    :force => false
    }.deep_merge(opts)

    if options[:force] || (options[:invoice][:amount] > 0)
      invoice = PackageInvoice.create(options[:invoice])
      invoice.pend!
      invoice
    end

  end

  # Cria o primeiro invoice para os primeiros 30 dias mas dobra seu valor
  # (correspondente a taxa de setup)
  def create_invoice_and_setup
    create_invoice(:invoice => {
      :amount => self.price * 2,
      :description => "Fatura refrente aos primeiros 30 dias e a taxa de adesão do plano #{self.name}"})
  end

  # Cria ordem do gateway padrão (i.e PagSeguro) com as informações dos invoices
  # cujo estado é pending. É possível passar informações adicionais para a ordem.
  def create_order(options={})
    order_options = {
      :order_id => self.id,
      :items => self.invoices.pending_payment.collect { |i| i.to_order_item }
    }.merge(options)

    order = PagSeguro::Order.new(order_options[:order_id])
    order_options[:items].each { |item| order.add(item) }

    return order
  end
end
