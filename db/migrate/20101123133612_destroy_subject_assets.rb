# -*- encoding : utf-8 -*-
class DestroySubjectAssets < ActiveRecord::Migration
  def self.up
    drop_table :subject_assets
  end

  def self.down
    create_table "subject_assets", :force => true do |t|
      t.string   "asset_type",                :null => false
      t.integer  "asset_id",                  :null => false
      t.integer  "subject_id",                 :null => false
      t.integer  "view_count", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end
end
