class Invoice < ActiveRecord::Base
  belongs_to :plan

  validates_presence_of :period_start, :period_end, :amount

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
