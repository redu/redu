class PackageInvoice < Invoice
  include AASM

  belongs_to :plan

  validates_presence_of :amount

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
    transitions :to => :closed, :from => [:pending, :overdue]
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:pending, :overdue]
  end

  aasm_event :overdue do
    transitions :to => :overdue, :from => [:pending, :overdue, :waiting]
  end

  # Converte o invoice para um hash que pode ser utilizado para adicionar produtos
  # a ordem do gateway de pagamento (e.g PagSeguro)
  def to_order_item(item_options = {})
    args = {
      :id => self.id,
      :price => self.total,
      :description => self.description || self.generate_description
    }.merge(item_options)
  end

  # Calcula o total do Invoice (levando em conta o desconto e sem valores negativos)
  def total
    if self.amount >= self.discount
      self.amount - self.discount
    else
      0
    end
  end

  # Data limite para o pagamento
  def threshold_date
    self.period_start + Invoice::OVERDUE_DAYS
  end

  # Gera descrição amigável para o invoice
  def generate_description

    msg = "Fatura N. #{self.id} referente ao período de #{self.period_start} a " +
    "#{self.period_end} no plano #{self.plan.name}"

    discount_msg = ". Com desconto de R$ #{self.discount.round(2)}"
    msg << discount_msg if self.discount > 0

    return msg
  end

  def open?
    false
  end

  # Atualiza estado do Invoice de acordo com a data atual e a data de vencimento
  # de acordo com a seguinte regra:
  #
  #  se Date.today > deadline
  #   o estado vai para 'overdue' e o plano vai para 'block'
  #  se Date.today <- deadline e Date.today >= Invoice.period_start
  #   o estado vai para 'pending'
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
  end
end
