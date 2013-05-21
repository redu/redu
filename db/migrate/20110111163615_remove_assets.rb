# -*- encoding : utf-8 -*-
class RemoveAssets < ActiveRecord::Migration
  def self.up
    drop_table :assets

    # Removendo referencias a Asset em outras tabelas
    remove_column :asset_reports, :asset_id
    remove_column :student_profiles, :asset_id
  end

  def self.down
    create_table "assets", :force => true do |t|
      t.integer  "subject_id"
      t.integer  "assetable_id"
      t.string   "assetable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position",       :default => 0
      t.integer  "lazy_asset_id"
    end

    # Adicionando referencias a Asset em outras tabelas
    add_column :asset_reports, :asset_id, :integer
    add_column :student_profiles, :asset_id, :integer
  end
end
