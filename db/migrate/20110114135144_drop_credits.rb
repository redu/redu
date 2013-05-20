# -*- encoding : utf-8 -*-
class DropCredits < ActiveRecord::Migration
  def self.up
    drop_table :credits
  end

  def self.down
    create_table "credits", :force => true do |t|
      t.decimal  "value",         :precision => 8, :scale => 2, :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
      t.string   "payment_type"
      t.integer  "customer_id"
      t.string   "customer_type"
    end
  end
end
