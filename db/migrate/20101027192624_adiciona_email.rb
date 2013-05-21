# -*- encoding : utf-8 -*-
class AdicionaEmail < ActiveRecord::Migration
  def self.up
    create_table "emails", :force => true do |t|
      t.string   "from"
      t.string   "to"
      t.integer  "last_send_attempt", :default => 0
      t.text     "mail"
      t.datetime "created_on"
    end

  end

  def self.down
    drop_table :emails
  end
end
