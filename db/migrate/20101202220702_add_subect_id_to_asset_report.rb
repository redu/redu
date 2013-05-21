# -*- encoding : utf-8 -*-
class AddSubectIdToAssetReport < ActiveRecord::Migration
  def self.up
    add_column :asset_reports, :subject_id, :integer
  end

  def self.down
    remove_column :asset_reports, :subject_id
  end
end
