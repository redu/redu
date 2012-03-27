class Invoice < ActiveRecord::Base
  OVERDUE_DAYS = 15

  belongs_to :plan

  validates_presence_of :period_start, :period_end

  scope :pending, where(:state => "pending")
  scope :overdue, where(:state => "overdue")
  scope :pending_payment, where("state LIKE ? OR state LIKE ?", 'pending',
                                'overdue')
  # Retorna todos os invoices com period_end contido (intervalo fechado)
  # no período informado.
  # Invoice.of_period(Range)
  # Invoice.of_period(Date.new(2011, 04, 03)..Date.new(2011, 06, 01))
  scope :of_period, lambda { |period|
    where(:period_end => period)
  }
  # Feito desta forma, pois o billable pode ter sido destruído
  scope :of_billable, lambda { |billable_id, billable_type|
    where(:plan_id => Plan.where(:billable_id => billable_id,
                                 :billable_type => billable_type))
  }

  attr_protected :state

  # Manda o e-mail de vencimento
  def deliver_overdue_notice
    send_overdue_notice
  end

  def deliver_pending_notice
    self.send_pending_notice
  end

  # Calcula o total do Invoice (levando em conta possíveis descontos
  # ou adições)
  def total
    self.amount + self.previous_balance
  end

  protected

  # Marca o horário em que o pagamento foi feito
  def register_time
    self.due_at = Time.now
  end

  def send_pending_notice
    UserNotifier.pending_notice(self.plan.user, self, self.threshold_date).
      deliver
  end

  def send_overdue_notice
    UserNotifier.overdue_notice(self.plan.user, self).deliver
  end

  def send_confirmation_and_unlock_plan
    self.plan.activate! unless self.plan.pending_payment?
    self.send_payment_confirmation
  end

  def send_payment_confirmation
    UserNotifier.payment_confirmation(self.plan.user, self).deliver
  end
end
