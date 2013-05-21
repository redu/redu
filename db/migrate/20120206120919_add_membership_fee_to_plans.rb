# -*- encoding : utf-8 -*-
class AddMembershipFeeToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :membership_fee, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :plans, :membership_fee
  end
end
