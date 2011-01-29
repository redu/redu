class Invoice < ActiveRecord::Base
  belongs_to :plan

  validates_presence_of :period_start, :period_end, :amount

  named_scope :pending, :conditions => { :state => "pending" }

  attr_protected :state

  acts_as_state_machine :initial => :pending, :column => "state"
  state :pending
  state :closed
  # send_overdue_notice não é chamado na transição do autorelacionamento:
  # (overdue -> overdue). Quando for necessário enviar a notificações novamente
  # chamar o método deliver_overdue_notice
  state :overdue, :enter => :send_overdue_notice
  state :paid, :enter => :register_time, :after => :send_payment_confirmation

  event :close do
    transitions :from => :pending, :to => :closed
    transitions :from => :overdue, :to => :closed
  end

  event :pay do
    transitions :from => :pending, :to => :paid
    transitions :from => :overdue, :to => :paid
  end

  event :overdue do
    transitions :from => :pending, :to => :overdue
    transitions :from => :overdue, :to => :overdue
  end

  # Data limite para o pagamento
  def threshold_date
    self.period_end + 10
  end

  # Manda o e-mail de vencimento
  def deliver_overdue_notice
    send_overdue_notice
  end

  # Converte o invoice para um hash que pode ser utilizado para adicionar produtos
  # a ordem do gateway de pagamento (e.g PagSeguro)
  def to_order_item(item_options = {})
    args = {
      :id => self.id,
      :price => self.amount,
      :description => self.description || self.generate_description
    }.merge(item_options)
  end

  # Gera descrição amigável para o invoice
  def generate_description
    "Fatura N. #{self.id} referente ao período de #{self.period_start} a " +
    "#{self.period_end} no plano #{self.plan.name}"
  end

  protected

  def register_time
    self.due_at = Time.now
  end

  def send_payment_confirmation
    UserNotifier.deliver_payment_confirmation(self.plan.user, self)
  end

  def send_overdue_notice
    UserNotifier.deliver_overdue_notice(self.plan.user, self)
  end

end
