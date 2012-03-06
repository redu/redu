class Invoice < ActiveRecord::Base
  OVERDUE_DAYS = 5

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
    where(:plan_id => Plan.where(:billable_id => billable_id, :billable_type => billable_type))
  }

  attr_protected :state
end
