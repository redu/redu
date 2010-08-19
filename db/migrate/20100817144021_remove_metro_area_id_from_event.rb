class RemoveMetroAreaIdFromEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :metro_area_id
  end

  def self.down
    add_column :events, :metro_area_id, :integer
  end
end
