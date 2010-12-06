class AddPositionToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :position, :integer
  end

  def self.down
    remove_column :assets, :position
  end
end
