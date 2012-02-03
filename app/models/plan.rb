class Plan < ActiveRecord::Base
  include AASM

  serialize :billable_audit, Course

  belongs_to :billable, :polymorphic => true
  belongs_to :user
  has_many :invoices

  scope :blocked, where(:state => "blocked")

  validates_presence_of :price

  attr_protected :state

  aasm_column :state
  aasm_initial_state :active

  aasm_state :active
  aasm_state :blocked
  aasm_state :migrated

  aasm_event :block do
    transitions :to => :blocked, :from => [:active]
  end

  aasm_event :activate do
    transitions :to => :active, :from => [:blocked, :active]
  end

  aasm_event :migrate do
    transitions :to => :migrated, :from => [:active]
  end

  # TODO Refatorar lógica de migração
  #
  # Migra o plano atual para o new_plan setando os estados e criando associações
  # necesssárias. O método garante que o User e Billable serão os mesmos de self.
  #
  # plan.migrate_to(:name => "Novo", :members_limit => 90, :price => 1.99)
  #
  def migrate_to(new_plan_attrs)
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

  def self.from_preset(key, type="PackagePlan")
    plan = begin
             self.new.becomes(type.constantize)
             plan.type = plan.class.to_s
           rescue NameError
             PackagePlan.new
           end
    klass = plan.class
    plan.attributes = klass::PLANS.fetch(key, klass::PLANS[:free])
    plan
  end

  # Retorna true se há pelo menos um Invoice com estado 'overdue' ou 'pending'
  def pending_payment?
    self.invoices.pending.count > 0 || self.invoices.overdue.count > 0
  end

  # Serializa billable associado e salva com propósito de auditoria
  def audit_billable!
    self.billable_audit = self.billable
    save!
  end

  protected

  def days_in_period(from, to)
    return (to - from).round
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day
  end
end
