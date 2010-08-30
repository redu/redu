class AddCustomerIdCredits < ActiveRecord::Migration
  def self.up
    add_column :credits, :customer_id, :integer
  end

  def self.down
    remove_column :credits, :customer_id
  end
end
