# -*- encoding : utf-8 -*-
class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.date :period_start
      t.date :period_end
      t.date :due_at
      t.string :currency, :default => "BRL"
      t.string :state
      t.decimal :amount, :precision => 8, :scale => 2 
      t.text :description
      t.belongs_to :plan

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
