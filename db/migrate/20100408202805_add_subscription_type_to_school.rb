class AddSubscriptionTypeToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :subscription_type, :integer
  end

  def self.down
    remove_column :schools, :subscription_type
  end
end
