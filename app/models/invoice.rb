class Invoice < ActiveRecord::Base
  belongs_to :plan

  validates_presence_of :period_start, :period_end, :amount

  attr_protected :state

  acts_as_state_machine :initial => :pending, :column => "state"
  state :pending
  state :closed
  state :overdue
  state :paid

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
  end
end
