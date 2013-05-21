# -*- encoding : utf-8 -*-
class AddExistentToLazyAssets < ActiveRecord::Migration
  def self.up
    add_column :lazy_assets, :existent, :boolean
  end

  def self.down
    remove_column :lazy_assets, :existent
  end
end
