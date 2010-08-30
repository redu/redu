class AddStateAndPaymentTypeToCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :state, :string
    add_column :credits, :payment_type, :string
  end

  def self.down
    remove_column :credits, :state
    remove_column :credits, :payment_type
  end
end
