class Invoice < ActiveRecord::Base
  OVERDUE_DAYS = 5

  belongs_to :plan

  validates_presence_of :period_start, :period_end

  scope :pending, where(:state => "pending")
  scope :overdue, where(:state => "overdue")
  scope :pending_payment, where("state LIKE ? OR state LIKE ?", 'pending',
                                'overdue')
  # Retorna todos os invoices contidos (intervalo fechado) no período informado
  # Invoice.of_period(Range)
  # Invoice.of_period(Date.new(2011, 04, 03)..Date.new(2011, 06, 01))
  scope :of_period, lambda { |period|
    where(:period_start => period, :period_end => period)
  }
  scope :of_billable, lambda { |billable|
    where(:plan_id => billable.plans.collect(&:id).flatten)
  }

  attr_protected :state
end
