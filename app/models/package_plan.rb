# -*- encoding : utf-8 -*-
class PackagePlan < Plan

  PLANS = {
    :free => {
      :name => "Professor Grátis",
      :price => 0,
      :yearly_price => 0,
      :video_storage_limit => 10.megabytes,
      :file_storage_limit => 5.megabytes,
      :members_limit => 30
    },
    :professor_lite => {
      :name => "Professor Lite",
      :price => 13.99,
      :yearly_price => 139.90,
      :membership_fee => 13.99,
      :video_storage_limit => 30.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 70
    },
    :professor_standard => {
      :name => "Professor Standard",
      :price => 56.99,
      :yearly_price => 569.90,
      :membership_fee => 56.99,
      :video_storage_limit => 90.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 100
    },
    :professor_plus => {
      :name => "Professor Plus",
      :price => 243.99,
      :yearly_price => 2439.90,
      :membership_fee => 245.99,
      :video_storage_limit => 150.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 500
    },
    :instituicao_medio_tiny => {
      :name => "Instituição de Ensino Médio Tiny",
      :price => 600.00,
      :yearly_price => 5000.00,
      :membership_fee => 600.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 200
    },
    :instituicao_medio_lite => {
      :name => "Instituição de Ensino Médio Lite",
      :price => 870.00,
      :yearly_price => 7452.00,
      :membership_fee => 870.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 300
    },
    :instituicao_medio_standard => {
      :name => "Instituição de Ensino Médio Standard",
      :price => 1120.00,
      :yearly_price => 9888.00,
      :membership_fee => 1120.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 400
    },
    :instituicao_medio_plus => {
      :name => "Instituição de Ensino Médio Plus",
      :price => 1250.00,
      :yearly_price => 12000.00,
      :membership_fee => 1250.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
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
  # - Caso o invoice criado tenha total < 0, o mesmo será marcado como pago
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
    period_start = opts[:invoice].try(:[], :period_start) || Date.today
    period_end = period_start.advance(:days => 30)

    options = {
      :invoice => {
      :period_start => period_start,
      :period_end => period_end,
      :amount => self.price,
      :description => "Fatura referente à #{period_end - period_start + 1} dias no plano #{self.name}"
    },
    :force => false
    }.deep_merge(opts)

    if options[:force] || (options[:invoice][:amount] > 0)
      self.invoice = PackageInvoice.new(options[:invoice])
      self.invoice.pend!
      self.invoice.pay! if self.invoice.total <= 0
      self.invoice
    end

  end

  # Cria o primeiro invoice para os primeiros 30 dias + a taxa de adesão
  def create_invoice_and_setup
    create_invoice(:invoice => {
      :amount => self.price + (self.membership_fee || 0),
      :description => "Fatura refrente aos primeiros 30 dias#{self.membership_fee ? ' e a taxa de adesão': ''} no plano #{self.name}"})
  end
end
