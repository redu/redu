# -*- encoding : utf-8 -*-
class ChangeDiscountToPreviousBalanceOnInvoices < ActiveRecord::Migration
  def self.up
    rename_column :invoices, :discount, :previous_balance
  end

  def self.down
    rename_column :invoices, :previous_balance, :discount
  end
end
