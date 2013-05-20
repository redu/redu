# -*- encoding : utf-8 -*-
class CreateLazyAssets < ActiveRecord::Migration
  def self.up
    create_table :lazy_assets do |t|
      t.integer :subject_id
      t.string :lazy_type
      t.string :name
      t.integer :assetable_id
      t.string :assetable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :lazy_assets
  end
end
