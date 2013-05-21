# -*- encoding : utf-8 -*-
class Invoice < ActiveRecord::Base
  OVERDUE_DAYS = 15

  belongs_to :plan

  validates_presence_of :period_start, :period_end

  scope :pending, where(:state => "pending")
  scope :overdue, where(:state => "overdue")
  scope :to_calculate, where(:state => "open")
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

  # Cria o próximo invoice
  # - Leva em conta possíveis descontos
  def create_next_invoice
    previous_balance = self.total if self.total < 0
    previous_balance ||= 0

    self.plan.create_invoice({ :invoice => {
      :period_start => self.period_end.tomorrow,
      :previous_balance => previous_balance
    }})
  end

  def can_create_next_invoice?
    self.plan.billable && self.period_end < Date.today
  end

  def total_days
    (self.period_end - self.period_start + 1).to_i
  end

  protected

  # Marca o horário em que o pagamento foi feito
  def register_time
    self.due_at = Time.now
  end

  def send_pending_notice
    UserNotifier.delay(:queue => 'email').
      pending_notice(self.plan.user, self, self.threshold_date)
  end

  def send_overdue_notice
    UserNotifier.delay(:queue => 'email').overdue_notice(self.plan.user, self)
  end

  def send_confirmation_and_unlock_plan
    self.plan.activate! unless self.plan.pending_payment?
    self.send_payment_confirmation
  end

  def send_payment_confirmation
    UserNotifier.delay(:queue => 'email').
      payment_confirmation(self.plan.user, self)
  end
end
