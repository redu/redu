# -*- encoding : utf-8 -*-
class RemoveAnnotation < ActiveRecord::Migration
  def self.up
    drop_table :annotations
  end

  def self.down
    create_table "annotations", :force => true do |t|
      t.integer  "user_id",                    :null => false
      t.integer  "lecture_id",                 :null => false
      t.text     "content"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "asset_name", :default => ""
    end
  end
end
