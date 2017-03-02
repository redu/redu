# -*- encoding : utf-8 -*-
class PackageInvoice < Invoice
  include AASM

  belongs_to :plan

  validates_presence_of :amount

  scope :current, -> { where(current: true) }

  aasm_column :state
  aasm_initial_state :waiting

  aasm_state :waiting
  aasm_state :closed
  # send_overdue_notice não é chamado na transição do autorelacionamento:
  # (overdue -> overdue). Quando for necessário enviar a notificações novamente
  # chamar o método deliver_overdue_notice
  aasm_state :pending, :enter => :send_pending_notice
  aasm_state :overdue, :enter => :send_overdue_notice
  aasm_state :paid, :after_enter => [:register_time, :send_confirmation_and_unlock_plan]

  aasm_event :pend do
    transitions :to => :pending, :from => [:pending, :waiting]
  end

  aasm_event :close do
    transitions :to => :closed, :from => [:pending, :waiting]
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:pending, :overdue]
  end

  aasm_event :overdue do
    transitions :to => :overdue, :from => [:pending, :overdue, :waiting]
  end

  # Data limite para o pagamento
  def threshold_date
    self.period_start + Invoice::OVERDUE_DAYS
  end

  # Gera descrição amigável para o invoice
  def generate_description

    msg = "Fatura N. #{self.id} referente ao período de #{self.period_start} a " +
    "#{self.period_end} no plano #{self.plan.name}"

    discount_or_addition_msg = if self.previous_balance < 0
       ". Com desconto de R$ #{self.previous_balance.round(2)}"
    elsif self.previous_balance > 0
      ". Com adição de R$ #{self.previous_balance.round(2)}"
    end
    msg << discount_or_addition_msg if discount_or_addition_msg

    return msg
  end

  def open?
    false
  end

  # Atualiza a data final e retorna a diferença entre o amount e o que foi
  # de fato utilizado (de acordo com a nova data final)
  def refresh_amount(new_period_end)
    old_total_days = self.total_days
    self.update_attribute(:period_end, new_period_end)

    used = (self.amount / old_total_days * self.total_days)
    self.amount - used
  end

  # Atualiza a data final e o amount de acordo com a nova data final
  def refresh_amount!(new_period_end)
    old_total_days = self.total_days
    self.period_end = new_period_end

    used = (self.amount / old_total_days * self.total_days)
    self.amount = used
    self.save
  end

  # Atualiza estado do Invoice de acordo com a data atual e a data de vencimento
  # de acordo com a seguinte regra:
  #
  #  Para os invoices pendentes:
  #  - se Date.today > deadline
  #     o estado vai para 'overdue' e o plano vai para 'block'
  #  - se Date.today <- deadline e Date.today >= Invoice.period_start
  #     o estado vai para 'pending'
  #
  #   Para os invoices pagos:
  #   - Se já passou o período do invoice, o próximo é criado
  #
  # Caso a opção :block_plan = false o plano não é bloqueado quando o Invoice
  # está vencido (overdue).
  def self.refresh_states!(opts = {})
    opts = {
      :block_plan => true
    }.merge(opts)

    PackageInvoice.pending.each do |i|
      if Date.today > i.threshold_date
        i.overdue!
        i.plan.block! if opts[:block_plan] && !i.plan.blocked?
      elsif Date.today >= i.period_start && Date.today <= i.threshold_date
        i.pend!
      end
    end

    PackageInvoice.current.paid.each do |i|
      i.create_next_invoice if i.can_create_next_invoice?
    end
  end
end
