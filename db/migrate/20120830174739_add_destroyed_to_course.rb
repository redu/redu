class AddDestroyedToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :destroy_soon, :boolean, :default => false
    add_index :courses, :destroy_soon
  end

  def self.down
    remove_column :courses, :destroy_soon
  end
end
