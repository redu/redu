# -*- encoding : utf-8 -*-
class RemovePlanFromPlans < ActiveRecord::Migration
  def self.up
    remove_column :plans, :plan_id
  end

  def self.down
    add_column :plans, :plan_id, :integer
  end
end
