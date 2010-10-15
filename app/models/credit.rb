class Credit < ActiveRecord::Base
  belongs_to :user, :foreign_key => "customer_id"

  acts_as_state_machine :initial => :pending
  state :pending
  state :error
  state :approved
  state :disapproved

  event :approve do
    transitions :from => :pending, :to => :approved
  end

  event :disapprove do
    transitions :from => :pending, :to => :disapproved
  end

  event :failure do
    transitions :from => :pending, :to => :error # TODO salvar estado de "erro" no bd
  end

  def self.total(customer_id)
    self.connection.execute("SELECT SUM(value) FROM credits WHERE customer_id = #{customer_id}").fetch_row.first
  end
end
