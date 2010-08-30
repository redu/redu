class AddPublishedToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :published, :boolean, {:default => true}
  end

  def self.down
    remove_column :courses, :published
    
  end
end
