class AddDestroySoonToSpace < ActiveRecord::Migration
  def self.up
    add_column :spaces, :destroy_soon, :boolean, :default => false
    add_index :spaces, :destroy_soon
  end

  def self.down
    remove_column :spaces, :destroy_soon
  end
end
