# -*- encoding : utf-8 -*-
class AddSubscriptionTypeToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :subscription_type, :integer, :default => 1 # Sem moderação
  end

  def self.down
    remove_column :courses, :subscription_type
  end
end
