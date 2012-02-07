class LicensedInvoice < Invoice
  include AASM

  belongs_to :plan
  has_many :licenses, :foreign_key => :invoice_id

  scope :retrieve_by_month_year, lambda { |month, year|
    where("period_start between ? and ?",
          Date.civil(year, month, 1),
          Date.civil(year, month, 1).end_of_month) }
  scope :actual,  order("period_start DESC").limit(1)
  scope :open, where(:state => "open")

  validates_presence_of :period_start

  aasm_column :state
  aasm_initial_state :open

  aasm_state :open
  aasm_state :pending
  aasm_state :paid

  aasm_event :pend do
    transitions :to => :pending, :from => [:open]
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:pending]
  end

  def generate_description
    msg = "#{self.plan.name} - Licença #{self.plan.price} - Capacidade de Armazenamento #{self.plan.file_storage_limit}"
  end

  def self.refresh_amounts!
    LicensedInvoice.open.each do |i|
      if i.period_end < Date.today
        days_of_month = i.period_end.end_of_month.day.to_f
        i.amount = (i.plan.price / days_of_month) *
          (i.period_end - i.period_start) * i.licenses.count
        i.pend!
        i.save
      end
    end
  end
end
