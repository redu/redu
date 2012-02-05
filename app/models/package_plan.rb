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
    }
  }

  validates_presence_of :members_limit, :yearly_price

  # Cria um Invoice com o amount correto para este plano. Por default,
  # a data final é 30 dias após a data inicial (hoje).
  #
  # O invoice só é gerado se o amount informado for maior do que zero. Para forçar
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
  # invoice.period_end
  # => Sat, 12 Feb 2011
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
