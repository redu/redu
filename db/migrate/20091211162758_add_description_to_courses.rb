class AddDescriptionToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :description, :text
  end

  def self.down
    remove_column :courses, :description
  end
end
