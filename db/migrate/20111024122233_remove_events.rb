# -*- encoding : utf-8 -*-
class RemoveEvents < ActiveRecord::Migration
  def self.up
    drop_table :events
  end

  def self.down
    create_table "events", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "owner"
      t.datetime "start_time"
      t.datetime "end_time"
      t.text     "description"
      t.string   "location"
      t.string   "state"
      t.integer  "eventable_id"
      t.string   "eventable_type"
    end
  end
end
