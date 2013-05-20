# -*- encoding : utf-8 -*-
class AddLazyAssetIdToLecture < ActiveRecord::Migration
  def self.up
    add_column :lectures, :lazy_asset_id, :integer
  end

  def self.down
    remove_column :lectures, :lazy_asset_id
  end
end
