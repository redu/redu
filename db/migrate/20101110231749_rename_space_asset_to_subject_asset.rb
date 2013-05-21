# -*- encoding : utf-8 -*-
class RenameSpaceAssetToSubjectAsset < ActiveRecord::Migration
  def self.up
		rename_table :space_assets, :subject_assets
  end

  def self.down
		rename_table :subject_assets, :space_assets
  end
end
