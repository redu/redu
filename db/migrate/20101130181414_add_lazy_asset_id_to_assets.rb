# -*- encoding : utf-8 -*-
class AddLazyAssetIdToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :lazy_asset_id, :integer
  end

  def self.down
    remove_column :assets, :lazy_asset_id
  end
end
