class Plan < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true
  belongs_to :user

  # Para quando houver upgrade/downgrade
  has_one :changed_to, :class_name => "Plan", :foreign_key =>  :plan_id
  belongs_to :changed_from, :class_name => "Plan", :foreign_key => :plan_id

  validates_presence_of :members_limit, :price

  acts_as_state_machine :initial => :active, :column => 'status'
  state :active
  state :closed
  state :migrated

  event :close do
    transitions :from => :active, :to => :closed
  end

  event :migrate do
    transitions :from => :active, :to => :migrated
  end

  # Migra o plano atual para o new_plan setando os estados e criando associações
  # necesssárias. O método garante que o User e Billable serão os mesmos de self.
  #
  # plan.migrate_to(:name => "Novo", :members_limit => 90, :price => 1.99)
  #
  def migrate_to(new_plan_attrs)
    new_plan_attrs[:changed_from] = self
    new_plan_attrs[:user] = self.user
    new_plan_attrs[:billable] = self.billable

    new_plan = Plan.new(new_plan_attrs)

    Plan.transaction do
      new_plan.save!
      self.migrate!
    end

    return new_plan
  end

  # Cria um Invoice com o amount correto para este plano. O amount do invoice é
  # calculado dividindo-se o price do plano pela quantidade de dias restantes até
  # o AppConfig.billing_date como no exemplo abaixo:
  #
  # plan.price
  # => 20.00
  # Date.today
  # => Thu, 13 Jan 2011
  # invoice = plan.create_invoice
  # invoice.amount
  # => 11.61 # (31 dias - 13 dias) * (20 / 31 dias)
  def create_invoice
    #TODO depende de Invoice
  end
end
