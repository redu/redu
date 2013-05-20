# -*- encoding : utf-8 -*-
class ChangeDueAtToDateTimeInInvoice < ActiveRecord::Migration
  def self.up
    change_column :invoices, :due_at, :datetime
  end

  def self.down
    change_column :invoices, :due_at, :date
  end
end
