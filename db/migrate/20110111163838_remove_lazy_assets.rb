# -*- encoding : utf-8 -*-
class RemoveLazyAssets < ActiveRecord::Migration
  def self.up
    drop_table :lazy_assets

    remove_column :exams, :lazy_asset_id
    remove_column :lectures, :lazy_asset_id
  end

  def self.down
    create_table "lazy_assets", :force => true do |t|
      t.integer  "subject_id"
      t.string   "lazy_type"
      t.string   "name"
      t.integer  "assetable_id"
      t.string   "assetable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "existent"
    end

    add_column :exams, :lazy_asset_id, :integer
    add_column :lectures, :lazy_asset_id, :integer
  end
end
