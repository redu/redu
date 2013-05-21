# -*- encoding : utf-8 -*-
class AddAuditToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :audit, :text
  end

  def self.down
    remove_column :invoices, :audit
  end
end
