# -*- encoding : utf-8 -*-
class RemoveAcquisition < ActiveRecord::Migration
  def self.up
  	drop_table :acquisitions
  end

  def self.down
  	create_table "acquisitions", :force => true do |t|
	  t.integer  "course_id"
	  t.integer  "acquired_by_id"
	  t.string   "acquired_by_type"
	  t.datetime "created_at"
	  t.datetime "updated_at"
	  t.decimal  "value",            :precision => 8, :scale => 2, :default => 0.0
	end
  end
end
