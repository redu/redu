class AddCustomerTypeCredits < ActiveRecord::Migration
  def self.up
     add_column :credits, :customer_type, :string
  end

  def self.down
    remove_column :credits, :customer_type
  end
end
