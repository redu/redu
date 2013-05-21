# -*- encoding : utf-8 -*-
class AddTypeToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :type, :string
  end

  def self.down
    remove_column :invoices, :type
  end
end
