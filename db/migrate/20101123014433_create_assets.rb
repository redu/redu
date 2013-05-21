# -*- encoding : utf-8 -*-
class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :subject_id
      t.references :assetable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
