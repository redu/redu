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

  # Calcula o amount do invoice de acordo com a quantidade de licenças
  # utilizadas, preço do plano e dias de uso.
  # Altera o estado do invoice para 'pending'
  #
  # invoice.calculate_amount!
  # => #<BigDecimal:104a9fbf0,'0.0',9(18)>
  def calculate_amount!
    days_of_month = self.period_end.end_of_month.day.to_f
    # Preço diário * # de dias usados * # de licenças pagáveis utilizadas
    self.amount = (self.plan.price / days_of_month) *
      (self.period_end - self.period_start + 1) * self.licenses.payable.count
    self.pend!
    self.save
    self.amount
  end

  # Duplica todas as licenças em uso para o invoice passado como parâmetro
  def duplicate_licenses_to(invoice)
    self.licenses.in_use.each do |l|
      new = l.clone
      new.attributes = {:created_at => nil, :updated_at => nil,
                        :period_start => Date.today,
                        :invoice => invoice }
      new.save
    end
  end

  # Verifica quais invoices em aberto já podem ter o amount calculado e:
  # - calcula o amount do invoice em questão
  # - cria um novo invoice
  # - duplica todas as licenças em uso para o novo invoice
  # - Atualiza todas as licenças em uso do invoice em questão para
  #   terem um period_end
  def self.refresh_open_invoices!
    LicensedInvoice.open.each do |i|
      if i.period_end <= Date.today

        i.calculate_amount!
        new_invoice =  i.plan.create_invoice({:invoice => {
          :period_start => Date.today + 1.day }
        })
        i.duplicate_licenses_to(new_invoice)

        # Atualiza as licenças do invoice fechado para terem um period_end
        License.update_all(["period_end = ? ", Date.yesterday],
                           ["id IN (?)", i.licenses.collect(&:id)])
      end
    end
  end
end
