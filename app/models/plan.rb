class Plan < ActiveRecord::Base
  include AASM

  serialize :billable_audit

  belongs_to :billable, :polymorphic => true
  belongs_to :user
  has_many :invoices

  scope :blocked, where(:state => "blocked")

  validates_presence_of :price, :user

  attr_protected :state

  aasm_column :state
  aasm_initial_state :active

  aasm_state :active
  aasm_state :blocked, :enter => [:send_blocked_notice]
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

  def self.from_preset(key, type="PackagePlan")
    plan = begin
             type.constantize.new
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
    options = Hash.new
    options[:include] = [:courses, :partner_environment_association] if self.billable.is_a? Environment
    self.billable_audit = self.billable.serializable_hash(options)
    self.save!
  end

  def send_blocked_notice
    UserNotifier.blocked_notice(self.user, self).deliver
  end

  # Retorna o invoice atual
  #
  # subject.plan
  # => #<PackageInvoice:0x103f20f18>
  def invoice
    self.invoices.where(:current => true).first
  end

  # Seta o invoice como o atual
  #
  # subject.invoice = invoice
  # => #<PackageInvoice:0x103f20f18>
  # subject.invoice
  # => #<PackageInvoice:0x103f20f18>
  #
  # subject.invoice = nil
  # => nil
  # subject.invoice
  # => nil
  def invoice=(new_invoice)
    self.invoice.try(:update_attribute, :current, false)
    new_invoice.try(:update_attributes, :current => true, :plan => self)
    self.invoice
  end

  # Realiza setup necessário à migração
  def setup_for_migration
    nil # Deve ser implementado nos planos que necessitam de setup
  end

  # Efetua a migração para o plano passado como parâmetro
  def migrate_to(new_plan)
    previous_balance = unless self.invoice.paid?
      self.invoice.close!
      self.invoice.total
    else
      balance = if self.invoice.total < 0
                   self.invoice.total # Valor já entra como desconto
                 else
                   - self.invoice.total # Valor convertido para desconto
                 end
      balance
    end

    new_invoice = new_plan.create_invoice(:invoice => {
      :period_start => Date.today,
      :period_end => self.invoice.period_end,
      :previous_balance => previous_balance
    })
    self.billable.plan = new_plan
    new_plan.setup_for_migration

    self.invoice.update_attributes(:period_end => Date.yesterday)
  end
end
