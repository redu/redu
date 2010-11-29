class AddExistentToLazyAssets < ActiveRecord::Migration
  def self.up
    add_column :lazy_assets, :existent, :boolean, :default => false
  end

  def self.down
    remove_column :lazy_assets, :existent
  end
end
