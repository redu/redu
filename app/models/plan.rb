class Plan < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true
  belongs_to :user
  # Para quando houver upgrade/downgrade
  has_one :changed_to, :class_name => "Plan", :foreign_key =>  :plan_id
  belongs_to :changed_from, :class_name => "Plan", :foreign_key => :plan_id
  has_many :invoices

  validates_presence_of :members_limit, :price

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

    new_plan = Plan.new(new_plan_attrs)

    Plan.transaction do
      new_plan.save!
      self.migrate!
    end

    return new_plan
  end

  # Cria um Invoice com o amount correto para este plano. O amount do invoice é
  # calculado dividindo-se o price do plano pela quantidade de dias restantes até
  # o primeiro dia do próximo mês. Os valores passdos através do invoice_options
  # têm precedência sobre os calculados. Como no exemplo abaixo:
  #
  # plan.price
  # => 20.00
  # Date.today
  # => Thu, 13 Jan 2011
  # invoice = plan.create_invoice
  # invoice.amount
  # => 11.61 # (31 dias - 13 dias) * (20 / 31 dias)
  def create_invoice(invoice_options = {})
    options = {
      :period_start => Date.today.tomorrow,
      :period_end => Date.today.at_end_of_month,
      :amount => amount_until_next_month
    }.deep_merge!(invoice_options)

    self.invoices.create(options)
  end

  # Calcula o montante do perído informado porporcional ao preço do plano. O default
  # do from é Date.today e do to é o primeiro dia do próximo mês.
  def amount_until_next_month
    from = Date.tomorrow
    to = Date.today.at_end_of_month
    # Montante por dia
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

  protected

  def days_in_period(from, to)
    return (to - from).round
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day
  end
end
