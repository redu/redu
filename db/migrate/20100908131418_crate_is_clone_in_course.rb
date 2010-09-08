class CrateIsCloneInCourse < ActiveRecord::Migration
  def self.up
     add_column :courses, :is_clone, :boolean,  :default => false
  end

  def self.down
    remove_column :courses, :is_clone
  end
end
