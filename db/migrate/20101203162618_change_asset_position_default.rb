# -*- encoding : utf-8 -*-
class ChangeAssetPositionDefault < ActiveRecord::Migration
  def self.up
    change_column :assets, :position, :integer, :default => 0
  end

  def self.down
    change_column :assets, :position, :integer
  end
end
