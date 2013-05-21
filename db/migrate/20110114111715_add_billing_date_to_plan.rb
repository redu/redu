# -*- encoding : utf-8 -*-
class AddBillingDateToPlan < ActiveRecord::Migration
  def self.up
    add_column :plans, :billing_date, :date
  end

  def self.down
    remove_column :plans, :billing_date
  end
end
