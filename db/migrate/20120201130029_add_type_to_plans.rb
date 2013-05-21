# -*- encoding : utf-8 -*-
class AddTypeToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :type, :string
  end

  def self.down
    remove_column :plans, :type
  end
end
