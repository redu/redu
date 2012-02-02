class Invoice < ActiveRecord::Base
  OVERDUE_DAYS = 5

  belongs_to :plan

  validates_presence_of :period_start, :period_end, :amount

  scope :pending, where(:state => "pending")
  scope :overdue, where(:state => "overdue")
  scope :pending_payment, where("state LIKE ? OR state LIKE ?", 'pending',
                                'overdue')

  attr_protected :state

end
