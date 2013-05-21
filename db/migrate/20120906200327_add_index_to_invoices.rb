# -*- encoding : utf-8 -*-
class AddIndexToInvoices < ActiveRecord::Migration
  def self.up
    add_index :invoices, :plan_id
  end

  def self.down
    remove_index :invoices, :plan_id
  end
end
