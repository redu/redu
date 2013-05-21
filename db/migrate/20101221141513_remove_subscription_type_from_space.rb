# -*- encoding : utf-8 -*-
class RemoveSubscriptionTypeFromSpace < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :subscription_type
  end

  def self.down
    add_column :spaces, :subscription_type, :integer
  end
end
