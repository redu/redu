# -*- encoding : utf-8 -*-
class AddAssetNameToAnnotations < ActiveRecord::Migration
  def self.up
    add_column :annotations, :asset_name, :string, :default => ""
  end

  def self.down
  end
end
