class Plan < ActiveRecord::Base

  PLANS = {
    :professor_standard => {
      :name => "Professor Standard",
      :price => 49.99,
      :yearly_price => 499.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 30.gigabytes,
      :members_limit => 50
    },
    :professor_lite => {
      :name => "Professor Lite",
      :price => 24.99,
      :yearly_price => 249.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 20.gigabytes,
      :members_limit => 20
    },
    :free => {
      :name => "Professor Grátis (3 meses)",
      :price => 0,
      :yearly_price => 0,
      :video_storage_limit => 10.megabytes,
      :file_storage_limit => 2.megabytes,
      :members_limit => 10
    },
    :instituicao_lite => {
      :name => "Instituição Lite",
      :price => 149.99,
      :yearly_price => 1499.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 10.gigabytes,
      :members_limit => 100
    },
    :instituicao_standard => {
      :name => "Instituição Standard",
      :price => 279.99,
      :yearly_price => 2799.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 20.gigabytes,
      :members_limit => 200
    },
    :instituicao_plus => {
      :name => "Instituição Plus",
      :price => 399.99,
      :yearly_price => 3999.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 30.gigabytes,
      :members_limit => 100
    },
    :empresas_lite => {
      :name => "Empresa Lite",
      :price => 59.99,
      :yearly_price => 599.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 20.gigabytes,
      :members_limit => 30
    },
    :empresas_standard => {
      :name => "Empresa Standard",
      :price => 89.99,
      :yearly_price => 899.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 20.gigabytes,
      :members_limit => 50
    },
    :empresas_plus => {
      :name => "Empresa Plus",
      :price => 149.99,
      :yearly_price => 1499.99,
      :video_storage_limit => 1.gigabyte,
      :file_storage_limit => 30.gigabytes,
      :members_limit => 100
    },
  }

  belongs_to :billable, :polymorphic => true
  belongs_to :user
  # Para quando houver upgrade/downgrade
  has_one :changed_to, :class_name => "Plan", :foreign_key =>  :plan_id
  belongs_to :changed_from, :class_name => "Plan", :foreign_key => :plan_id
  has_many :invoices

  validates_presence_of :members_limit, :price, :yearly_price

  attr_protected :state

  acts_as_state_machine :initial => :active, :column => 'status'
  state :active
  state :closed
  state :migrated

  event :close do
    transitions :from => :active, :to => :closed
  end

  event :migrate do
    transitions :from => :active, :to => :migrated
  end

  # Migra o plano atual para o new_plan setando os estados e criando associações
  # necesssárias. O método garante que o User e Billable serão os mesmos de self.
  #
  # plan.migrate_to(:name => "Novo", :members_limit => 90, :price => 1.99)
  #
  def migrate_to(new_plan_attrs)
    new_plan_attrs[:changed_from] = self
    new_plan_attrs[:user] = self.user
    new_plan_attrs[:billable] = self.billable

    new_plan = Plan.create(new_plan_attrs)
    # Migrando invoices antigas (self) para o novo plano

    new_plan.invoices << self.invoices
    new_plan.create_invoice

    # Seta relacionamento entre self e new_plan através de um trigger
    self.migrate!

    return new_plan
  end

  # Cria um Invoice com o amount correto para este plano. O amount do invoice é
  # calculado dividindo-se o price do plano pela quantidade de dias restantes até
  # o último dia do mês atual. Caso nenhuma opção seja informada, a data inicial
  # será Date.tomorrow e a final de hoje a 30 dias, além disso o amount é
  # calculado para esse período
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
    invoice_options = {
      :period_start => Date.today.tomorrow,
      :period_end => Date.today.advance(:days => 30),
      :amount => self.price
    }.merge(opts)

    self.invoices.create(invoice_options)
  end

  # Cria o primeiro invoice para os primeiros 30 dias mas dobra seu valor
  # (correspondente a taxa de setup)
  def create_invoice_and_setup
    create_invoice(:amount => self.price * 2,
                   :description => "Fatura refrente aos primeiros 30 dias e a taxa de adesão do plano #{self.name}")
  end

  # Calcula o montante do perído informado porporcional ao preço do plano. O default
  # do from é Date.today e do to é o primeiro dia do próximo mês.
  def amount_until_next_month
    from = Date.today
    to = Date.today.at_end_of_month
    # Montante por dia
    per_day = self.price / days_in_current_month

    return per_day * days_in_period(from, to)
  end

  def amount_between(from, to)
    per_day = self.price / days_in_current_month
    return per_day * days_in_period(from, to)
  end

  def days_in_current_month
    days_in_month(Date.today.year, Date.today.month)
  end

  # Qtd de dias completos entre day_start e day_end. Começa a contar
  # do dia seguinte.
  def complete_days_in(day_start, day_end)
    return days_in_current_month unless day_start && day_end
    days_in_period(day_start, day_end)
  end

  # Cria ordem do gateway padrão (i.e PagSeguro) com as informações dos invoices
  # cujo estado é pending. É possível passar informações adicionais para a ordem.
  def create_order(options={})
    order_options = {
      :order_id => self.id,
      :items => self.invoices.pending.collect { |i| i.to_order_item }
    }.merge(options)

    order = PagSeguro::Order.new(order_options[:order_id])
    order_options[:items].each { |item| order.add(item) }

    return order
  end

  def self.from_preset(key)
    self.new(PLANS.fetch(key, PLANS[:free]))
  end

  # Há invoices com pagamento pendente?
  def pending_payment?
    self.invoices.pending.count > 0
  end

  protected

  def days_in_period(from, to)
    return (to - from).round
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day
  end
end
