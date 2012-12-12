class Plan < ActiveRecord::Base
  include AASM

  serialize :billable_audit

  belongs_to :billable, :polymorphic => true
  belongs_to :user
  has_many :invoices

  scope :blocked, where(:state => "blocked")
  # Necessário, pois em produção o scope gerado automaticamente estava
  # fazendo cache de consultas anteriores
  scope :current, where(:current => true)

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
  # - Faz o tratamento correto para o invoice atual
  #   . Se estiver aberto ou pendente, a data final é atualizada, ele é
  #     fechado e o valor repassado como adição para o novo invoice
  #   . Se estiver pago, permanecerá pago e o desconto é repassado para o
  #     novo invoice
  # - Cria um novo invoice com o valor relativo a quantidade de dias
  #   e com desconto (caso houver) do invoice anterior
  def migrate_to(new_plan)
    opts = {
      :period_start => Date.today
    }
    opts[:period_end] = self.invoice.period_end if self.invoice
    opts[:previous_balance] = discharge_payment_need!

    # Seta o valor relativo para o novo invoice
    if self.invoice
      relative_amount = new_plan.price / (opts[:period_end] -
                                          self.invoice.period_start + 1) *
                                          (opts[:period_end] -
                                           opts[:period_start] + 1)
      opts[:amount] = relative_amount
    end

    new_plan.user = self.user
    self.billable.plan = new_plan
    new_invoice = new_plan.create_invoice(:invoice => opts, :force => true)
    new_plan.setup_for_migration
    self.migrate!
  end

  # Bloqueia o acesso ao billable e todos os seus filhos na hierarquia
  # Utilizado apenas diretamente no console
  def block_all_access!
    if self.billable.is_a? Environment
      environment = self.billable
      courses = self.billable.courses.includes(:spaces =>
                                               [:subjects => :lectures])
      spaces = courses.collect(&:spaces).flatten

      Environment.update_all(["blocked = ?", true], ["id = ?", self.billable])
    else
      courses = [self.billable]
      spaces = courses[0].spaces.includes(:subjects => :lectures)
    end
    subjects = spaces.collect(&:subjects).flatten
    lectures = subjects.collect(&:lectures).flatten

    Course.update_all(["blocked = ?", true], ["id IN (?)", courses])
    Space.update_all(["blocked = ?", true], ["id IN (?)", spaces])
    Subject.update_all(["blocked = ?", true], ["id IN (?)", subjects])
    Lecture.update_all(["blocked = ?", true], ["id IN (?)", lectures])
  end

  protected

  # Calcula quanto do plano atual está pendente e fecha tais faturas
  # - Marca como "closed" as faturas com pagamento necessário
  # - Retorna o valor das faturas recém-fechadas
  # - É possível que este valor seja negativo, isto indica
  #   que o responsável pelo plano possui crédito
  #
  # plan.calc_payment_need
  # => #<BigDecimal:10d1076e8,'0.8146E3',18(36)>
  def discharge_payment_need!
    if self.invoice.nil?
      0
    elsif !(self.invoices.pending_payment +
            self.invoices.open).empty?
      self.invoice.refresh_amount!(Date.yesterday)
      # Necessário, pois a atualização da data,
      # feita na linha de cima, não estava sendo levada em
      # conta no fechamento da fatura.
      self.invoices.reload

      # Fecha todos os invoices pendentes para adicionar
      # o valor ao novo invoice
      need_payment_invoices = self.invoices.pending_payment +
        self.invoices.open
      pending_values = need_payment_invoices.collect do |inv|
        inv.close!
        inv.total
      end
      pending_values.sum
    else # Se já estiver pago
      credit = self.invoice.refresh_amount(Date.yesterday)
      balance = if self.invoice.total < 0
                  # Valor já entra como desconto
                  self.invoice.total - credit
                else
                  # Valor convertido para desconto
                  - credit
                end
    end
  end
end
