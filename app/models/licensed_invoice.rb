class LicensedInvoice < Invoice
  belongs_to :partner_plan
  has_many :licenses, :as => :invoice

  validates_presence_of :period_start
  scope :retrieve_by_month_year, lambda { |month, year|
    where("period_start between ? and ?",
          Date.civil(year, month, 1),
          Date.civil(year, month, 1).end_of_month) }
  scope :actual,  order("period_start DESC").limit(1)

  def generate_description
    msg = "#{self.plan.name} - Licença #{self.plan.price} - Capacidade de Armazenamento #{self.plan.file_storage_limit}"
  end
end
