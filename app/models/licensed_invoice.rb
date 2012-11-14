class LicensedInvoice < Invoice
  include AASM

  belongs_to :plan
  has_many :licenses, :foreign_key => :invoice_id

  scope :retrieve_by_month_year, lambda { |month, year|
    where("period_start between ? and ?",
          Date.civil(year, month, 1),
          Date.civil(year, month, 1).end_of_month) }
  scope :actual,  order("period_start DESC").limit(1)

  validates_presence_of :period_start

  aasm_column :state
  aasm_initial_state :open

  aasm_state :open
  aasm_state :pending, :after_enter => [:calculate_amount!, :create_next_invoice,
                                        :mark_as_paid_if_necessary,
                                        :set_licenses_period_end,
                                        :send_pending_notice]
  aasm_state :paid, :after_enter => [:register_time,
                                     :send_confirmation_and_unlock_plan]
  aasm_state :overdue, :enter => :send_overdue_notice
  aasm_state :closed, :enter => [:calculate_amount!, :set_licenses_period_end]

  aasm_event :pend do
    transitions :to => :pending, :from => [:open, :pending]
  end

  aasm_event :pay do
    transitions :to => :paid, :from => [:pending, :overdue]
  end

  aasm_event :overdue do
    transitions :to => :overdue, :from => [:pending]
  end

  aasm_event :close do
    transitions :to => :closed, :from => [:open, :pending]
  end

  # Data limite para o pagamento
  def threshold_date
    self.period_end + Invoice::OVERDUE_DAYS
  end

  def generate_description
    msg = "#{self.plan.name} - Licença #{self.plan.price} - Capacidade de Armazenamento #{self.plan.file_storage_limit}"
  end

  def create_license(user, role, course)
    self.licenses << License.create(:name => user.display_name,
                                    :login => user.login,
                                    :email => user.email,
                                    :period_start => DateTime.now,
                                    :role => role,
                                    :invoice => self,
                                    :course => course)
  end

  # Cria o próximo invoice com todas as licenças relativas aos usuários atuais
  def create_next_invoice
    new_invoice = super
    self.replicate_licenses_to(new_invoice)
    new_invoice
  end


  # Atualiza os estados dos invoices
  # - Para os abertos, passa para pending, caso a contagem o cálculo do
  #   amount já possa ser feito
  # - Para os pendentes, verifica se devem ser passados para vencido/atrasado
  #   ou se apenas o reenvio do email deve ser feito
  def self.refresh_states!
    LicensedInvoice.open.each do |i|
      i.pend! if i.can_create_next_invoice?
    end

    LicensedInvoice.pending.each do |i|
      if i.threshold_date < Date.today
        i.overdue!
        i.plan.block! unless i.plan.blocked?
      else
        i.deliver_pending_notice
      end
    end
  end

  # Apenas atualiza a data, visto que o amount será atualizado no
  # calculate_amount!
  def refresh_amount!(new_period_end)
    self.update_attribute(:period_end, new_period_end)
  end

  protected

  # Calcula o amount do invoice de acordo com a quantidade de licenças
  # utilizadas, preço do plano e dias de uso.
  # Altera o estado do invoice para 'pending'
  #
  # invoice.calculate_amount!
  # => #<BigDecimal:104a9fbf0,'0.0',9(18)>
  def calculate_amount!
    self.remove_duplicated_licenses

    days_of_month = 30
    # Preço diário
    factor = self.plan.price / days_of_month
    # Valor diário * quantidade de dias da licença
    amount = self.licenses.payable.collect do |license|
      if license.period_end.nil?
        # Não salva, apenas altera temporariamente
        license.period_end = self.period_end
      end
      license.total_days * factor
    end

    self.update_attributes(:amount => amount.sum)
  end

  # Marca invoice recém pendente como pago, caso possua total < 0
  def mark_as_paid_if_necessary
    self.pay! if self.total <= 0
  end

  # Duplica todas as licenças em uso para o invoice passado como parâmetro
  def replicate_licenses_to(invoice)
    self.licenses.in_use.each do |l|
      new = l.clone
      new.attributes = {:created_at => nil, :updated_at => nil,
                        :period_start => invoice.period_start,
                        :invoice => invoice }
      new.save
    end
  end

  # Atualiza as licenças em uso do invoice para terem um period_end
  def set_licenses_period_end
    License.update_all(["period_end = ? ", self.period_end],
                       ["id IN (?)", self.licenses.in_use.collect(&:id)])
  end

  # Redefinindo método de Invoice
  def send_pending_notice
    UserNotifier.licensed_pending_notice(self.plan.user, self, self.threshold_date).
      deliver
  end

  def remove_duplicated_licenses
    sql = <<-EOS
      select * from (
        select * from licenses l ORDER BY l.id DESC
      ) l2
      GROUP BY login, invoice_id, course_id, period_end, period_start
      HAVING count(*) > 1
    EOS
    duplicated = License.find_by_sql(sql)
    License.where(:id => duplicated.collect(&:id)).delete_all
  end
end
