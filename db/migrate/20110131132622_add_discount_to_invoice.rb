# -*- encoding : utf-8 -*-
class AddDiscountToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :discount, :decimal, :precision => 8, :scale => 2,
      :default => 0
  end

  def self.down
    remove_column :invoices, :discount
  end
end
