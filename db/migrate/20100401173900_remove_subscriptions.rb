class RemoveSubscriptions < ActiveRecord::Migration
  def self.up
    drop_table :subscriptions
    rename_column :schools, :subscription_id, :subscription_type
  end

  def self.down
  end
end
