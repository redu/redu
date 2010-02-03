class AddDescriptionToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :description, :text, :null => false
  end

  def self.down
    remove_column :courses, :description
  end
end
