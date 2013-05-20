# -*- encoding : utf-8 -*-
class CreateAssetReport < ActiveRecord::Migration
  def self.up
    create_table :asset_reports do |t|
      t.references :asset
      t.references :student_profile
      t.boolean :done, :default => false
    end
  end

  def self.down
    drop_table :asset_reports
  end
end
