# -*- encoding : utf-8 -*-
class RemoveBulletins < ActiveRecord::Migration
  def self.up
    drop_table :bulletins
  end

  def self.down
    create_table "bulletins", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
      t.integer  "owner"
      t.integer  "bulletinable_id"
      t.string   "bulletinable_type"
    end
  end
end
