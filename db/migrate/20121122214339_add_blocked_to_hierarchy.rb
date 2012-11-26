class AddBlockedToHierarchy < ActiveRecord::Migration
  def self.up
    add_column :environments, :blocked, :boolean, :default => false
    add_column :courses, :blocked, :boolean, :default => false
    add_column :spaces, :blocked, :boolean, :default => false
    add_column :subjects, :blocked, :boolean, :default => false
    add_column :lectures, :blocked, :boolean, :default => false
  end

  def self.down
    remove_column :environments, :blocked
    remove_column :courses, :blocked
    remove_column :spaces, :blocked
    remove_column :subjects, :blocked
    remove_column :lectures, :blocked
  end
end
